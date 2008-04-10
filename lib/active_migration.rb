$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_migration/base'
require 'active_migration/key_mapper'
require 'active_migration/callbacks'

ActiveMigration::Base.class_eval do
  include ActiveMigration::KeyMapper
  include ActiveMigration::Callbacks
end