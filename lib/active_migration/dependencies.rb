module ActiveMigration
  module Dependencies

    def self.included(base)

      base.class_eval do
        alias_method_chain :run, :dependencies

        class << self
          attr_accessor :dependencies, :completed
          def set_dependencies(dependencies)
            @dependencies = dependencies
          end
          alias dependencies= set_dependencies
          def completed?
            @completed
          end
          def is_completed
            @completed = true
          end
          alias completed completed?
          def dependencies
            @dependencies || []
          end
        end

      end
    end

    def run_with_dependencies
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