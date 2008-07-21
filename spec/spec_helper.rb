begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'active_migration'

module ActiveRecord
  class Base
  end
end

class Product
end

module Legacy
  class Product
  end
end

class ProductMigration < ActiveMigration::Base

  set_active_model      'Product'

  set_legacy_model      'Legacy::Product'

  set_reference_field   :name

  set_mappings          [
                        ['name'      , 'name']
                        ]

end
