class ProductFourMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product'

  map              [['supplier_id' , 'supplier_id', :products]]

end