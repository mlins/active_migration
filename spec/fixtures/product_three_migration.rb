class ProductThreeMigration < ActiveMigration::Base

  set_active_model    'Product'

  set_legacy_model    'Legacy::Product'

  map                 [['name', 'name']]

  write_key_map       true

end