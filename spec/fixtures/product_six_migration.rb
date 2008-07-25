class ProductSixMigration < ActiveMigration::Base

  set_active_model          'Product'

  set_legacy_model          'Legacy::Product'

  set_reference_field       :name

  set_active_record_update  true

  set_mappings              [
                            ['name' , 'name'],
                            ]

end