class ProductSixMigration < ActiveMigration::Base

  set_active_model          'Product',
                            :update

  set_legacy_model          'Legacy::Product'

  set_reference_field       :name

  set_mappings              [
                            ['name' , 'name'],
                            ]

end