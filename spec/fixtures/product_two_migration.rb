class ProductTwoMigration < ActiveMigration::Base

  set_active_model      'Product'

  set_legacy_model      'Legacy::Product'

  set_reference_field   :name

  set_mappings          [
                        ['name' , 'name']
                        ]

  set_dependencies      [:manufacturer_migration]

end