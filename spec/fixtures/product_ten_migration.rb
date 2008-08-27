class ProductTenMigration < ActiveMigration::Base

  set_active_model 'Product',
                   :mode => :update

  set_legacy_model 'Legacy::Product',
                   :limit => 5,
                   :offset => 3 # This is for specing only, this element will be deleted.

  map              [['name', 'name']]

end