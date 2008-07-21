require File.dirname(__FILE__) + '/spec_helper.rb'

#require 'rubygems'; require 'ruby-debug'

describe "A migration" do

  before do
    @migration = ProductTwoMigration.new
    @dependency = mock("migration_object1", :null_object => true)
    @legacy_model = mock("ar_object1", :null_object => true)
    @active_model = mock("ar_object2", :null_object => true)
    @legacy_model.stub!(:name).and_return("Beer")
    @active_model.stub!(:name=).and_return("Beer")
    Product.stub!(:new).and_return(@active_model)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_model])
  end

  it "should instansiate it's dependencies" do
    ProductMigration.should_receive(:new).and_return(@dependency)
    @dependency.should_receive(:run)
    @migration.run
  end

end
