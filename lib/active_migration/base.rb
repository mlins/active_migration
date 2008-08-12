module ActiveMigration

  # Generic ActiveMigration exception class.
  class ActiveMigrationError < StandardError
  end

  # There are always two datasets involved with ActiveMigration.  Your *Legacy* dataset and you
  # *Active* dataset.  Legacy being the dataset you will be migrationg from.  Active being the dataset you are migrating to.
  #
  # These terms (legacy and active) are used to refer to:
  #
  #   - databases
  #   - models
  #   - records
  #   - fields
  #
  # ActiveMigration::Base is subclassed by your *Migration*.  It defines a DSL similar to ActiveRecord, in which it feel more
  # like a configuration.
  #
  # == Typical Usage:
  #
  #   class PostMigration < ActiveMigration::Base
  #
  #     set_active_model 'Post'
  #
  #     set_legacy_model 'Legacy::Post'
  #
  #     map              [[:name_tx,        :name],
  #                       [:description_tx, :description],
  #                       [:date,           :created_at]]
  #
  #   end
  #
  class Base

    cattr_accessor :logger

    class << self

      attr_accessor :legacy_model, :active_model, :mappings, :legacy_find_options, :active_record_mode

      # Sets the legacy model to be migrated from.  It's wise to namespace your legacy
      # models to prevent class duplicates.
      #
      # Also, *args can be passed a Hash to hold finder options for legacy record lookup.
      #
      # Note: If you set :limit, it will stagger your selects with an offset. This is intended to break up large datasets
      #       to conserve memory.  Keep in mind, for this functionality to work :offset(because it is needed internally)
      #       can never be specified, it will be deleted.
      #
      #   set_legacy_model Legacy::Post
      #
      #   set_legacy_model Legacy::Post,
      #                    :conditions => 'some_field = value',
      #                    :order => 'this_field ASC',
      #                    :limit => 5
      #
      def set_legacy_model(legacy_model, *args)
        @legacy_model = eval(legacy_model)
        args[0].delete(:offset) if args[0]
        @legacy_find_options = args[0] unless args.empty?
        @legacy_find_options ||= {}
      end
      alias legacy_model= set_legacy_model

      # Sets the active model to be migrated to.
      #
      # Also, an additional parameter for the method of instantiation.  Valid
      # parameters are: :create or :update.  Defaults to :create.  Use this if records already
      # exist in the active database.  Lookup with :update will be done via the PK of the legacy
      # record.
      #
      #   set_active_model 'Post'
      #
      #   set_active_model 'Post',
      #                    :update
      #
      def set_active_model(active_model, mode=:create)
        @active_model = eval(active_model)
        @active_record_mode = mode
      end
      alias active_model= set_active_model

      # Sets the mappings for the migration.  Mappings are specified in a multidimensional array.  Each array
      # elment contains another array in which the legacy field is the first element and the active field is
      # the second elment.
      #
      #   map [['some_old_field', 'new_spiffy_field']]
      #
      def map(mappings)
        @mappings = mappings
      end
      alias mappings= map

    end

    # Runs the migration.
    #
    #   MyMigration.new.run
    #
    def run
      count_options = self.class.legacy_find_options.dup
      count_options.delete(:order)
      count_options.delete(:group)
      count_options.delete(:limit)
      count_options.delete(:offset)
      @num_of_records = self.class.legacy_model.count(count_options)
      if self.class.legacy_find_options[:limit] && (@num_of_records > self.class.legacy_find_options[:limit])
        run_in_batches @num_of_records
      else
        run_normal
      end
      logger.info("#{self.class.to_s} migrated all #{@num_of_records} records successfully.")
    end

    protected

    # This is called everytime there is an error.  You should override this method
    # and handle it in the apporpriate way.
    #
    def handle_error()
    end

    # This is called everytime there is a successful record migration.  You should override this
    # method and handle it in the appropriate way.
    #
    def handle_success()
    end

    private

    def run_in_batches(num_of_records) #:nodoc:
      num_of_last_record = 0
      while num_of_records > 0 do
        self.class.legacy_find_options[:offset] = num_of_last_record
        num_of_last_record += self.class.legacy_find_options[:limit]
        num_of_records -= self.class.legacy_find_options[:limit]
        run_normal
      end
    end

    def run_normal #:nodoc:
      legacy_records = self.class.legacy_model.find(:all, self.class.legacy_find_options)
      legacy_records.each do |@legacy_record|
        find_or_create_active_record
        migrate_record
        unless @skip
          save
          unless @skip
            logger.debug("#{self.class.to_s} successfully migrated a record from #{self.class.legacy_model.table_name} to #{self.class.active_model.table_name}. The legacy record had an id of #{@legacy_record.id}. The active record has an id of #{@active_record.id}")
          else
            handle_success
          end
        else
          handle_success
        end
        @skip = false
      end
    end

    def find_or_create_active_record
      @active_record = (self.class.active_record_mode == :create) ? self.class.active_model.new : self.class.active_model.find(@legacy_record.id)
    end

    def migrate_record #:nodoc:
      self.class.mappings.each do |@mapping|
        migrate_field
      end unless self.class.mappings.nil?
    end

    # FIXME - #migrate_field needs to be refactored.
    def migrate_field #:nodoc:
      begin
        eval("@active_record.#{@mapping[1]} = @legacy_record.#{@mapping[0]}")
      rescue
        logger.error("#{self.class.to_s} had an error while trying to migrate #{self.class.legacy_model.table_name}.#{@mapping[0]} to #{self.class.active_model.table_name}.#{@mapping[1]}. The legacy record had an id of #{@legacy_record.id}.")
        handle_error
      end
    end

    def save #:nodoc:
      while @active_record.changed? && !@skip
        if @active_record.save
          handle_success
        else
          while !@active_record.valid? && !@skip do
            errors = @active_record.errors.collect {|field,msg| field + " " + msg}.join(", ")
            logger.error("#{self.class.to_s} had an error while trying to save the active_record. The associated legacy_record had an id of #{@legacy_record.id}. The active record had the following errors: #{errors}")
            handle_error
          end
        end
      end
    end

  end
end