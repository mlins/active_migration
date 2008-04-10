module ActiveMigration
  class Base
    
    class << self
      
      attr_accessor :legacy_model_name, :active_model_name, :mappings, :legacy_find_options, :display_field, :max_rows
      
      def set_max_rows(max_rows)
        @max_rows = max_rows.to_i
      end
      alias max_rows= set_max_rows
      
      def max_rows
        @max_rows ||= 50
        @max_rows
      end
      
      def set_legacy_model(legacy_model_name)
        @legacy_model_name = "Legacy::" + legacy_model_name.to_s.classify
      end
      alias legacy_model_name= set_legacy_model
      
      def set_active_model(active_model_name)
        @active_model_name = active_model_name.to_s.classify
      end
      alias active_model_name= set_active_model
      
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
      
      def set_display_field(display_field)
        @display_field = display_field.to_s
      end
      alias display_field= set_display_field
      
    end
    
    def run
      @legacy_model = eval("#{self.class.legacy_model_name}")
      @active_model = eval("#{self.class.active_model_name}")
      num_of_records = @legacy_model.count
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
        puts "Batch | Offset: " + num_of_last_record.to_s + " | Limit " + self.class.max_rows.to_s + " | Records left: " + num_of_records.to_s
        self.class.legacy_find_options[:offset] = num_of_last_record
        self.class.legacy_find_options[:limit] = self.class.max_rows
        num_of_last_record += self.class.max_rows
        num_of_records -= self.class.max_rows
        run_normal
      end
    end
    
    def run_normal
      legacy_records = @legacy_model.find(:all, self.class.legacy_find_options)
      legacy_records.each do |legacy_record|
        active_record = @active_model.new
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
        eval("active_record.#{mapping[:active_field]} = legacy_record.#{mapping[:legacy_field]}")
      rescue
        error = "could not be retrieved as #{mapping[:legacy_field]} from the legacy database -- probably doesn't exist."
        eval("active_record.#{mapping[:active_field]} = handle_error(active_record, self.class.display_field, mapping[:active_field], error)")
      end
    end
    
    def save_active_record(active_record, legacy_record)
      if active_record.save
        handle_success(active_record, self.class.display_field)
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
          new_value = handle_error(model, self.class.display_field, field, msg)
        end
        eval("model.#{field} = new_value.chomp")
      end
    end
    
    def handle_error(model, display_field, error_field, error_message)
      puts "********************************************************************"
      begin
        puts "Failed on " + model.instance_eval(display_field).to_s + " because '" + error_field.to_s + "' " + error_message.to_s
      rescue
        puts "Failed on associated model: #{model.class.to_s} because #{error_field.to_s} #{error_message.to_s}"
      end
      puts "The current value of '#{error_field.to_s}' is: '" + model.instance_eval(error_field).to_s + "'"
      print "Please enter a new value for '#{error_field}': "
      new_value = gets
      puts "********************************************************************"
      new_value.chomp
    end
    
    def handle_success(model, display_field)
      puts "Successfully migrated " + model.instance_eval(display_field)
    end
    
  end
end