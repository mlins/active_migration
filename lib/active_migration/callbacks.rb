module ActiveMigration
  module Callbacks
    
    CALLBACKS = %w(before_run after_run 
                   before_migrate_record after_migrate_record 
                   before_migrate_field after_migrate_field 
                   before_save_active_record after_save_active_record)
    
    def self.included(base)
      [:run, :migrate_record, :migrate_field, :save_active_record].each do |method|
        base.send :alias_method_chain, method, :callbacks
      end
    end
    
    def before_run() end
    def after_run() end
    def run_with_callbacks
      before_run
      run_without_callbacks
      after_run
    end
    
    def before_migrate_record(active_record, legacy_record) end
    def after_migrate_record(active_record, legacy_record) end
    def migrate_record_with_callbacks(active_record, legacy_record)
      before_migrate_record(active_record, legacy_record)
      migrate_record_without_callbacks(active_record, legacy_record)
      after_migrate_record(active_record, legacy_record)
    end
    
    def before_migrate_field(active_record, legacy_record, mapping) end
    def after_migrate_field(active_record, legacy_record, mapping) end
    def migrate_field_with_callbacks(active_record, legacy_record, mapping)
      before_migrate_field(active_record, legacy_record, mapping)
      migrate_field_without_callbacks(active_record, legacy_record, mapping)
      after_migrate_field(active_record, legacy_record, mapping)
    end
    
    def before_save_active_record(active_record, legacy_record) end
    def after_save_active_record(active_record, legacy_record) end
    def save_active_record_with_callbacks(active_record, legacy_record)
      before_save_active_record(active_record, legacy_record)
      save_active_record_without_callbacks(active_record, legacy_record)
      after_save_active_record(active_record, legacy_record)
    end
    
  end
end