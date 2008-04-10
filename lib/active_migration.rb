$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined? ActiveSupport
  active_support_path = File.dirname(__FILE__) + "/../../activesupport/lib"
  if File.exist?(active_support_path)
    $:.unshift active_support_path
    require 'active_support'
  else
    require 'rubygems'
    gem 'activesupport'
    require 'active_support'
  end
end

require 'active_migration/base'
require 'active_migration/key_mapper'
require 'active_migration/callbacks'

ActiveMigration::Base.class_eval do
  include ActiveMigration::KeyMapper
  include ActiveMigration::Callbacks
end
