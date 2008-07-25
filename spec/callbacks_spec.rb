# require File.dirname(__FILE__) + '/spec_helper.rb'
#
# #require 'rubygems'; require 'ruby-debug'
#
# describe "A migration" do
#
#   before do
#     @migration = ProductMigration.new
#     @legacy_model = mock("ar_object1", :null_object => true)
#     @active_model = mock("ar_object2", :null_object => true)
#     @legacy_model.stub!(:name).and_return("Beer")
#     @active_model.stub!(:name=).and_return("Beer")
#     Product.stub!(:new).and_return(@active_model)
#     Legacy::Product.stub!(:count).and_return(1)
#     Legacy::Product.stub!(:find).and_return([@legacy_model])
#   end
#
#   it "should call #before_run" do
#     @migration.should_receive(:before_run)
#     @migration.run
#   end
#
#   it "should call #before_migrate_record" do
#     @migration.should_receive(:before_migrate_record)
#     @migration.run
#   end
#
#   it "should call #before_migrate_field" do
#     @migration.should_receive(:before_migrate_field)
#     @migration.run
#   end
#
#   it "should call #after_migrate_field" do
#     @migration.should_receive(:after_migrate_field)
#     @migration.run
#   end
#
#   it "should call #after_migrate_record" do
#     @migration.should_receive(:after_migrate_record)
#     @migration.run
#   end
#
#   it "should call #after_run" do
#     @migration.should_receive(:after_run)
#     @migration.run
#   end
#
# end
