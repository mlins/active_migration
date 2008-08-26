require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_one_migration'
require File.dirname(__FILE__) + '/fixtures/product_ten_migration'

describe "A migration" do

  before do
    ActiveMigration::Base.logger = mock('logger', :null_object => true)
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :id => 1, :name= => 'Beer', :save => true)
    @active_record.stub!(:changed?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    @migration = ProductOneMigration.new
  end

  describe "when active_record_mode is set to :create" do

    create_callbacks = ActiveMigration::Callbacks::CALLBACKS - %w(before_update after_update)

    create_callbacks.each do |callback|
      it "should call ##{callback}" do
        @migration.should_receive(callback).once
        @migration.run
      end
    end

  end

  describe "when active_record_mode is set to :update" do

    before do
      @migration = ProductTenMigration.new
      Product.stub!(:find).and_return(@active_record)
    end

    update_callbacks = ActiveMigration::Callbacks::CALLBACKS - %w(before_create after_create)

    update_callbacks.each do |callback|
      it "should call ##{callback}" do
        @migration.should_receive(callback).once
        @migration.run
      end
    end

  end

end
