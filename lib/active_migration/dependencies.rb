module ActiveMigration
  # Dependencies are supported by ActiveRecord in this module.  If you set some dependencies
  # they'll be ran before Base#run is called.  Specifying dependencies is easy:
  #
  #   set_dependencies  [:supplier_migration, :manufacturer_migration]
  #
  module Dependencies

    def self.included(base)
      base.class_eval do
        alias_method_chain :run, :dependencies
        class << self
          attr_accessor :dependencies, :completed
          # Sets the dependencies for the migration
          #
          def set_dependencies(dependencies)
            @dependencies = dependencies
          end
          alias dependencies= set_dependencies
          def completed? #:nodoc:
            @completed
          end
          def is_completed #:nodoc:
            @completed = true
          end
          alias completed completed?
          def dependencies #:nodoc:
            @dependencies || []
          end
        end
      end
    end

    def run_with_dependencies(skip_dependencies=false) #:nodoc:
      if skip_dependencies
        run_without_dependencies
      else
        self.class.dependencies.each do |dependency|
          migration = dependency.to_s.camelize.constantize
          unless migration.completed?
            puts "Running(dependency) #{dependency.to_s}"
            migration.new.run
            migration.is_completed
          end
        end
        run_without_dependencies unless self.class.completed?
      end
    end

  end
end
