require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_one_migration'
require File.dirname(__FILE__) + '/fixtures/product_five_migration'
require File.dirname(__FILE__) + '/fixtures/product_six_migration'
require File.dirname(__FILE__) + '/fixtures/product_seven_migration'
require File.dirname(__FILE__) + '/fixtures/product_eight_migration'

describe 'A migration' do

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
  end

  it "should find the legacy records" do
    Legacy::Product.should_receive(:find).and_return([@legacy_record])
    ProductOneMigration.new.run
  end

  it "should create a new active record" do
    Product.should_receive(:new).and_return(@active_record)
    ProductOneMigration.new.run
  end

  it "should get the legacy name value" do
    @legacy_record.should_receive(:name).and_return("Beer")
    ProductOneMigration.new.run
  end

  it "should set the active name value to the legacy value" do
    @active_record.should_receive(:name=).with("Beer").and_return("Beer")
    ProductOneMigration.new.run
  end

  it "should attempt to save the active record" do
    @active_record.should_receive(:save).and_return(true)
    ProductOneMigration.new.run
  end

  it "should call #handle_success" do
    @migration = ProductOneMigration.new
    @migration.should_receive(:handle_success)
    @migration.run
  end

  describe "with specified find parameters (other than limit and offset)" do

    it "should find the legacy records with the specified parameters" do
      Legacy::Product.should_receive(:find).with(:all, {:conditions => ['name = ?', 'matt'], :include => :manufacturer}).and_return([@legacy_record])
      ProductFiveMigration.new.run
    end

  end

  describe "with the skip flag set before #migrate_field" do

    before do
      @migration = ProductSevenMigration.new
      @active_record.stub!(:valid?).and_return(false)
      @active_record.stub!(:errors).and_return([])
    end

    it "should not receive #save" do
      @active_record.should_not_receive(:save)
      @migration.run
    end

    it "should receive #handle_success" do
      @migration.should_receive(:handle_success)
      @migration.run
    end

  end

  describe "with the skip flag set in #handle_error" do

    before do
      @migration = ProductEightMigration.new
      @active_record.stub!(:save).and_return(false)
      @active_record.stub!(:valid?).and_return(false)
      @active_record.stub!(:errors).and_return([])
    end

    it "should only call save once and then skip the migration" do
      @active_record.should_receive(:save).once.and_return(false)
      @migration.run
    end

    it "should receive #handle_success" do
      @migration.should_receive(:handle_success)
      @migration.run
    end

  end

  describe "with specified limit and offset in find parameters" do

    before do
      @legacy_recordset = []
      10.times {@legacy_recordset.push(@legacy_record)}
      Legacy::Product.stub!(:count).and_return(10)
      Legacy::Product.stub!(:find).and_return(@legacy_recordset)
    end

    it "should not use the specified offset in the find parameters" do
      Legacy::Product.should_not_receive(:find).with(:all, {:limit => 5, :offset => 3})
      ProductOneMigration.new.run
    end

    it "should call find with a limit of max_rows(5) and an offset of 0 once" do
      Legacy::Product.should_receive(:find).with(:all, {:limit => 5, :offset => 0}).once.and_return(@legacy_recordset)
      ProductOneMigration.new.run
    end

    it "should call find with a limit of max_rows(5) and an offset of 5 once" do
      Legacy::Product.should_receive(:find).with(:all, {:limit => 5, :offset => 5}).once.and_return(@legacy_recordset)
      ProductOneMigration.new.run
    end

  end

  describe "with the update flag set for the active model" do

    before do
      Product.stub!(:find).and_return(@active_record)
    end

    it "should call find on the active model" do
      Product.should_receive(:find).with(1).and_return(@active_record)
      ProductSixMigration.new.run
    end

    it "should not create a new active record" do
      Product.should_not_receive(:new)
      ProductSixMigration.new.run
    end

  end

  describe "with invalid data in the active record" do

    before do
      @errors = mock('errors_object', :null_object => true)
      @active_record.stub!(:name).and_return('Beer')
      @active_record.stub!(:save).and_return(false)
      @active_record.stub!(:save!).and_return(true)
      @active_record.stub!(:valid?).and_return(false, true)
      @active_record.stub!(:errors).and_return(@errors)
      @migration = ProductOneMigration.new
      @migration.stub!(:handle_error).and_return("new_value")
    end

    it "should attempt to save the active record" do
      @active_record.should_receive(:save).and_return(false)
      @migration.run
    end

    it "should call #handle_error" do
      @migration.should_receive(:handle_error)
      @migration.run
    end

  end

end
