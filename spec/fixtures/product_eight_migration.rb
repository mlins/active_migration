class ProductEightMigration < ActiveMigration::Base

  set_active_model 'Product'

  set_legacy_model 'Legacy::Product'

  map              [['name', 'name']]

  def handle_error
    @skip = true
  end

end