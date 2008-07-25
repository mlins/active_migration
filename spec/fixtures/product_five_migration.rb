class ProductFiveMigration < ActiveMigration::Base

  set_active_model          'Product'

  set_legacy_model          'Legacy::Product'

  set_reference_field       :name

  set_legacy_find_options   :conditions => {:name => "Matt"}

  set_mappings              [
                            ['name' , 'name'],
                            ]

end