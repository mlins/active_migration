begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'active_migration'

Legacy = Module.new
ActiveRecord = Module.new
Product = Class.new
Legacy::Product = Class.new
ActiveRecord::Base = Class.new