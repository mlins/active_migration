class ProductNineMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product'

  map              [['name', 'name']]

  def before_save
    @validate_record = false
  end

end