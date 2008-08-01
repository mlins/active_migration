require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_two_migration'

ManufacturerMigration = Class.new

describe "A migration" do

  before do
    ActiveMigration::Base.logger = mock('logger', :null_object => true)
    @dependent_record = mock("dependency_model", :run => nil)
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :id => 1, :name= => 'Beer', :save => true)
    @active_record.stub!(:new_record?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    ManufacturerMigration.stub!(:new).and_return(@dependent_record)
    ManufacturerMigration.stub!(:run).and_return(nil)
    ManufacturerMigration.stub!(:completed?).and_return(false)
    ManufacturerMigration.stub!(:is_completed).and_return(true)
  end

  it "should instansiate it's dependencies" do
    ManufacturerMigration.should_receive(:new).and_return(@dependent_record)
    ProductTwoMigration.new.run
  end

  it "should run it's dependencies" do
    @dependent_record.should_receive(:run).and_return(nil)
    ProductTwoMigration.new.run
  end

end
