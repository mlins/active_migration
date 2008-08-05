class ProductSevenMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product'

  map              [['name', 'name']]

  def before_migrate_field
    @skip = true
  end

end