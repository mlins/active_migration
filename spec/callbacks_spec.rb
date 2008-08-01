require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_one_migration'

describe "A migration" do

  before do
    ActiveMigration::Base.logger = mock('logger', :null_object => true)
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :id => 1, :name= => 'Beer', :save => true)
    @active_record.stub!(:new_record?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    @migration = ProductOneMigration.new
  end

  it "should call #before_run" do
    @migration.should_receive(:before_run).once
    @migration.run
  end

  it "should call #before_migrate_record" do
    @migration.should_receive(:before_migrate_record).once
    @migration.run
  end

  it "should call #before_migrate_field" do
    @migration.should_receive(:before_migrate_field).once
    @migration.run
  end

  it "should call #after_migrate_field" do
    @migration.should_receive(:after_migrate_field).once
    @migration.run
  end

  it "should call #after_migrate_record" do
    @migration.should_receive(:after_migrate_record).once
    @migration.run
  end

  it "should call #after_run" do
    @migration.should_receive(:after_run).once
    @migration.run
  end

end
