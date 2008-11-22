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
  #   - before_save (before_create, before_update)
  #   - *save*
  #   - after_save (after_create, after_update)
  #   - after_run
  #
  module Callbacks

    CALLBACKS = %w(before_run after_run
    before_migrate_record after_migrate_record
    before_migrate_field after_migrate_field
    before_save after_save before_create after_create
    before_update after_update)

    def self.included(base)#:nodoc:
      [:run, :migrate_record, :migrate_field, :save, :update, :create].each do |method|
        base.send :alias_method_chain, method, :callbacks
      end
      base.send :include, ActiveSupport::Callbacks
      base.define_callbacks *CALLBACKS
    end

    # This is called before you anything actually starts.
    #
    def before_run() end
    # This is called after everything else finishes.
    #
    def after_run() end
    def run_with_callbacks #:nodoc:
      callback(:before_run)
      run_without_callbacks
      callback(:after_run)
    end

    # This is called before the iteration of field migrations.
    #
    def before_migrate_record() end
    # This is called after the iteration of field migrations.
    #
    def after_migrate_record() end
    def migrate_record_with_callbacks #:nodoc:
      callback(:before_migrate_record)
      migrate_record_without_callbacks
      callback(:after_migrate_record)
    end

    # This is called before each field migration.
    #
    def before_migrate_field() end
    # This is called directly after each field migration.
    #
    def after_migrate_field() end
    def migrate_field_with_callbacks#:nodoc:
      callback(:before_migrate_field)
      migrate_field_without_callbacks
      callback(:after_migrate_field)
    end

    # This is called directly before the active record is saved.
    #
    def before_save() end
    # This is called directly after the active record is saved.
    #
    def after_save() end
    def save_with_callbacks
      callback(:before_save)
      save_without_callbacks
      callback(:after_save)
    end

    # This is only called before update if active_record_mode is set to :update.
    #
    def before_update() end
    # This is only called after update if active_record_mode is set to :update.
    #
    def after_update() end
    def update_with_callbacks
      callback(:before_update)
      update_without_callbacks
      callback(:after_update)
    end

    # This is only called before create if active_record_mode is set to :create(default).
    #
    def before_create() end
    # This is only called after update if active_record_mode is set to :create(default).
    #
    def after_create() end
    def create_with_callbacks
      callback(:before_create)
      create_without_callbacks
      callback(:after_create)
    end

    private

    def callback(method) #:nodoc:
      run_callbacks(method)
      send(method)
    end

  end
end
