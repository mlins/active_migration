require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_two_migration'

ManufacturerMigration = Class.new

describe "A migration" do

  before do
    @dependent_record = mock("dependency_model", :run => nil)
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :name= => 'Beer', :save => true)
    Product.stub!(:new).and_return(@active_record)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
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
