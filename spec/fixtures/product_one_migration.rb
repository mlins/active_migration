class ProductOneMigration < ActiveMigration::Base

  set_active_model      'Product'

  set_legacy_model      'Legacy::Product'

  set_reference_field   :name

  set_max_rows          5

  set_mappings          [
                        ['name' , 'name']
                        ]

end