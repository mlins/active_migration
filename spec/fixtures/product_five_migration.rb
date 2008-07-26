class ProductFiveMigration < ActiveMigration::Base

  set_active_model          'Product'

  set_legacy_model          'Legacy::Product',
                            :conditions => ['name = ?', 'matt'],
                            :include => :manufacturer

  set_reference_field       :name

  set_mappings              [
                            ['name' , 'name'],
                            ]

end