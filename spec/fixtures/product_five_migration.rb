class ProductFiveMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product',
                    :conditions => ['name = ?', 'matt'],
                    :include => :manufacturer

  map              [['name', 'name']]

end
