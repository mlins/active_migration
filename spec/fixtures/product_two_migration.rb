class ProductTwoMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product'

  map              [['name', 'name']]

  set_dependencies [:manufacturer_migration]

end