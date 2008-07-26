class ProductThreeMigration < ActiveMigration::Base

  set_active_model    'Product'

  set_legacy_model    'Legacy::Product'

  map                 [['name', 'name']]

  set_map_primary_key true

end