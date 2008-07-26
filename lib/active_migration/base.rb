module ActiveMigration

  # Generic ActiveRecord exception class.
  class ActiveMigrationError < StandardError
  end

  # There are always at least two datasets involved with ActiveMigration.  Your *Legacy* dataset and you
  # *Active* dataset.  Legacy being the dataset you will be migrationg from.  Active being the dataset you are migrating to.
  #
  # These terms (legacy and active) are used to refer to:
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
  #     set_active_model      'Post'
  #
  #     set_legacy_model      'Legacy::Post'
  #
  #     set_mappings          [
  #                           [:name_tx,          :name       ],
  #                           [:description_tx,   :description],
  #                           [:date,             :created_at ]
  #                           ]
  #
  #     set_reference_field   :title
  #
  #   end
  #
  class Base
    class << self

      attr_accessor :legacy_model, :active_model, :mappings, :legacy_find_options, :reference_field, :max_rows, :active_record_mode

      # This sets the maximum number of rows to pull from the database at once.  If you have a lot of fields in your table
      # that hold a lot of data, you may want to decrease this.  It could take up a lot of memory to pull down 500 records at once.
      # You may want to increase this to make your migrations more effcient.
      # It defaults to 500.
      #
      #   set_max_rows  100
      #
      def set_max_rows(max_rows)
        @max_rows = max_rows.to_i
      end
      alias max_rows= set_max_rows

      def max_rows #:nodoc:
        @max_rows ||= 500
        @max_rows
      end

      # Sets the legacy model to be migrated from.  If you use GodWit it'll probably be
      # namespaced with Legacy (to avoid collisions).
      #
      #   set_legacy_model Legacy::Post
      #
      def set_legacy_model(legacy_model)
        @legacy_model = eval(legacy_model)
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
      #   set_mappings [
      #                ['some_old_field',   'new_spiffy_field'],
      #                ]
      #
      def set_mappings(mappings)
        @mappings = mappings
      end
      alias mappings= set_mappings

      # Sets your legacy find options.  This takes a hash that is compatiable with ActiveRecord#find.
      #
      # Note: If you're using SQL Server, you must specify this field because ActiveMigration uses offset
      #       by default (which SQL Server doesn't support).
      #
      #   set_legacy_find_options :conditions => 'some_field = value',
      #                           :order => 'this_field ASC'
      #
      def set_legacy_find_options(legacy_find_options)
        @legacy_find_options = legacy_find_options
      end
      alias legacy_find_options= legacy_find_options

      def legacy_find_options #:nodoc:
        @legacy_find_options ||= {}
        @legacy_find_options
      end

      # Sets a reference field to be passed to the #handle_success and #handle_error methods.  This is used
      # to display more friendly success/error messages on a per record scope.
      #
      #   set_reference_field :name
      #
      def set_reference_field(reference_field)
        @reference_field = reference_field.to_s
      end
      alias reference_field= set_reference_field

      def reference_field #:nodoc:
        @reference_field || :id
      end

    end

    # Runs the migration.
    #
    #   MyMigration.new.run
    #
    def run
      num_of_records = self.class.legacy_model.count
      if num_of_records > self.class.max_rows and (not self.class.legacy_find_options.nil? and
        not self.class.legacy_find_options.has_key?('limit') and
        not self.class.legacy_find_options.has_key?('offset'))
        run_in_batches num_of_records
      else
        run_normal
      end
    end

    # This is called everytime there is an error.  You should override this method
    # and handle it in the apporpriate way.
    #
    def handle_error(model, reference_field, error_field, error_message)
    end

    # This is called everytime there is a successful record migration.  You should override this
    # method and handle it in the appropriate way.
    #
    def handle_success(model, reference_field)
    end

    def run_in_batches(num_of_records) #:nodoc:
      num_of_last_record = 0
      while num_of_records > 0 do
        self.class.legacy_find_options[:offset] = num_of_last_record
        self.class.legacy_find_options[:limit] = self.class.max_rows
        num_of_last_record += self.class.max_rows
        num_of_records -= self.class.max_rows
        run_normal
      end
    end

    def run_normal #:nodoc:
      legacy_records = self.class.legacy_model.find(:all, self.class.legacy_find_options)
      legacy_records.each do |legacy_record|
        active_record = (self.class.active_record_mode == :create) ? self.class.active_model.new : self.class.active_model.find(legacy_record.id)
        migrate_record(active_record, legacy_record)
        save_active_record(active_record, legacy_record)
      end
    end

    def migrate_record(active_record, legacy_record) #:nodoc:
      self.class.mappings.each do |mapping|
        migrate_field(active_record, legacy_record, mapping)
      end
    end

    def migrate_field(active_record, legacy_record, mapping) #:nodoc:
      begin
        eval("active_record.#{mapping[1]} = legacy_record.#{mapping[0]}")
      rescue
        error = "could not be retrieved as #{mapping[0]} from the legacy database -- probably doesn't exist."
        eval("active_record.#{mapping[1]} = handle_error(active_record, self.class.reference_field, mapping[1], error)")
      end
    end

    def save_active_record(active_record, legacy_record) #:nodoc:
      if active_record.save
        handle_success(active_record, self.class.reference_field)
      else
        while !active_record.valid? do
          handle_errors(active_record)
        end
        active_record.save!
      end
    end

    def handle_errors(model) #:nodoc:
      model.errors.each do |field, msg|
        if model.instance_eval(field).kind_of? ActiveRecord::Base
          handle_errors(model.instance_eval(field))
          break
        elsif model.instance_eval(field).kind_of? Array
          model.instance_eval(field).each do |f|
            handle_errors(f)
          end
          break
        else
          new_value = handle_error(model, self.class.reference_field, field, msg)
        end
        eval("model.#{field} = new_value.chomp")
      end
    end

  end
end
