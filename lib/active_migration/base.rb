# Author:: Matt Lins  (mailto:mattlins@gmail.com)
#
# Typical Usage:
#
#   class PostMigration < ActiveMigration::Base
#
#     set_active_model      Post
#
#     set_legacy_model      Legacy::Post
#
#     set_mappings          [
#                           [:old_name,     :new_name   ],
#                           [:description,  :description],
#                           [:date,         :created    ]
#                           ]
#
#     set_reference_field   :title
#
#   end
#
module ActiveMigration
  class Base
    
    class ActiveMigrationError < StandardError
    end

    class ReferenceFieldNotSpecified < ActiveMigrationError
    end

    class << self
      
      attr_accessor :legacy_model, :active_model, :mappings, :legacy_find_options, :reference_field, :max_rows

      # This sets the maximum number of rows to pull from the database at once.  If you have a lot of records and tables
      # that hold a lot of data, you may want to decrease this.  It defaults to 50.
      def set_max_rows(max_rows)
        @max_rows = max_rows.to_i
      end
      alias max_rows= set_max_rows
      
      def max_rows
        @max_rows ||= 50
        @max_rows
      end
      
      # Sets the legacy model to be migrated from.
      #
      #   set_legacy_model Legacy::Post
      def set_legacy_model(legacy_model)
        @legacy_model = legacy_model
      end
      alias legacy_model= set_legacy_model
      
      # Sets the active model to be migrated to.
      #
      #   set_active_model Post
      def set_active_model(active_model)
        @active_model = active_model
      end
      alias active_model= set_active_model
      
      def set_mappings(mappings)
        @mappings = mappings
      end
      alias mappings= set_mappings
      
      def set_legacy_find_options(legacy_find_options)
        @legacy_find_options = legacy_find_options
      end
      alias legacy_find_options= legacy_find_options
      
      def legacy_find_options
        @legacy_find_options ||= {}
        @legacy_find_options
      end
      
      def set_reference_field(reference_field)
        @reference_field = reference_field.to_s
      end
      alias reference_field= set_reference_field
      
    end
    
    def run
      raise ReferenceFieldNotSpecified if self.class.reference_field.nil?
      num_of_records = self.class.legacy_model.count
      if num_of_records > self.class.max_rows and not (not self.class.legacy_find_options.nil? and self.class.legacy_find_options.has_key?('limit') and self.class.legacy_find_options.has_key?('offset')) 
        run_in_batches num_of_records
      else
        run_normal
      end
    end
    
    private
    
    def run_in_batches num_of_records
      num_of_last_record = 0
      while num_of_records > 0 do
        self.class.legacy_find_options[:offset] = num_of_last_record
        self.class.legacy_find_options[:limit] = self.class.max_rows
        num_of_last_record += self.class.max_rows
        num_of_records -= self.class.max_rows
        run_normal
      end
    end
    
    def run_normal
      legacy_records = self.class.legacy_model.find(:all, self.class.legacy_find_options)
      legacy_records.each do |legacy_record|
        active_record = self.class.active_model.new
        migrate_record(active_record, legacy_record)
        save_active_record(active_record, legacy_record)
      end
    end
    
    def migrate_record(active_record, legacy_record)
      self.class.mappings.each do |mapping|
        migrate_field(active_record, legacy_record, mapping)
      end
    end
    
    def migrate_field(active_record, legacy_record, mapping)
      begin
        eval("active_record.#{mapping[1]} = legacy_record.#{mapping[0]}")
      rescue
        error = "could not be retrieved as #{mapping[0]} from the legacy database -- probably doesn't exist."
        eval("active_record.#{mapping[1]} = handle_error(active_record, self.class.reference_field, mapping[1], error)")
      end
    end
    
    def save_active_record(active_record, legacy_record)
      if active_record.save
        handle_success(active_record, self.class.reference_field)
      else
        while !active_record.valid? do
          handle_errors(active_record)
        end
        active_record.save!
      end
    end
    
    def handle_errors(model)
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
    
    def handle_error(model, reference_field, error_field, error_message)
    end
    
    def handle_success(model, reference_field)
    end
    
  end
end