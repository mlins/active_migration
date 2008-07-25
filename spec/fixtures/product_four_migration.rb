class ProductFourMigration < ActiveMigration::Base

  set_active_model      'Product'

  set_legacy_model      'Legacy::Product'

  set_reference_field   :name

  set_use_maps          [:products]

  set_mappings          [
                        ['supplier_id' , 'supplier_id', {:map => :products}],
                        ]

end