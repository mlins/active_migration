class ProductSixMigration < ActiveMigration::Base

  set_active_model 'Product',
                   :update

  set_legacy_model 'Legacy::Product'

  map              [['name', 'name']]

end