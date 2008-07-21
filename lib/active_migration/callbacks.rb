module ActiveMigration
  # Callbacks are hooks into the ActiveMigration migration lifecycle.  This typical flow is
  # below.  Bold items are internal calls.
  #
  #   - before_run
  #   - *run*
  #   - before_migrate_record
  #   - *migrate_record*
  #   - after_migrate_record
  #   - before_migrate_field
  #   - *migrate_field*
  #   - after_migrate_field
  #   - before_save_active_record
  #   - *save_active_record*
  #   - after_save_active_record
  #   - after_run
  #
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

    # This is called before you anything actually starts.
    #
    def before_run() end
    # This is called after everything else finishes.
    #
    def after_run() end
    def run_with_callbacks #:nodoc:
      before_run
      run_without_callbacks
      after_run
    end

    # This is called before the iteration of field migrations.
    #
    def before_migrate_record(active_record, legacy_record) end
    # This is called after the iteration of field migrations.
    #
    def after_migrate_record(active_record, legacy_record) end
    def migrate_record_with_callbacks(active_record, legacy_record) #:nodoc:
      before_migrate_record(active_record, legacy_record)
      migrate_record_without_callbacks(active_record, legacy_record)
      after_migrate_record(active_record, legacy_record)
    end

    # This is called before each field migration.
    #
    def before_migrate_field(active_record, legacy_record, mapping) end
    # This is called directly after each field migration.
    #
    def after_migrate_field(active_record, legacy_record, mapping) end
    def migrate_field_with_callbacks(active_record, legacy_record, mapping) #:nodoc:
      before_migrate_field(active_record, legacy_record, mapping)
      migrate_field_without_callbacks(active_record, legacy_record, mapping)
      after_migrate_field(active_record, legacy_record, mapping)
    end

    # This is called directly before the active record is saved.
    #
    def before_save_active_record(active_record, legacy_record) end
    # This is called directly after the active record is saved.
    #
    def after_save_active_record(active_record, legacy_record) end
    def save_active_record_with_callbacks(active_record, legacy_record)
      before_save_active_record(active_record, legacy_record)
      save_active_record_without_callbacks(active_record, legacy_record)
      after_save_active_record(active_record, legacy_record)
    end

  end
end
