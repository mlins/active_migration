require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_one_migration'
require File.dirname(__FILE__) + '/fixtures/product_five_migration'
require File.dirname(__FILE__) + '/fixtures/product_six_migration'

describe 'A migration' do

  before do
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :name= => 'Beer', :save => true)
    Product.stub!(:new).and_return(@active_record)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
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
    @migration.should_receive(:handle_success).with(@active_record)
    @migration.run
  end

  describe "with specified find parameters (other than limit and offset)" do

    it "should find the legacy records with the specified parameters" do
      Legacy::Product.should_receive(:find).with(:all, {:conditions => ['name = ?', 'matt'], :include => :manufacturer}).and_return([@legacy_record])
      ProductFiveMigration.new.run
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

    describe "on one field" do

      before do
        @errors.stub!(:each).and_yield "name", "has an error"
      end

      it "should attempt to save the active record" do
        @active_record.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).with(@active_record, "name", "has an error").and_return("new_value")
        @migration.run
      end

      it "should attempt to save the active record again" do
        @active_record.should_receive(:save!).and_return(true)
        @migration.run
      end

    end

    describe "on a has_many association" do

      before do
        @errors.stub!(:each).and_yield "name", "is invalid"
        @associated_record = mock("asssociated_model", :errors => @errors, :name => "Miller", :name= => "Miller")
        @active_record.stub!(:name).and_return([@associated_record, @associated_record])
      end

      it "should attempt to save the active model" do
        @active_record.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).exactly(2).with(@associated_record, "name", "is invalid").and_return("new_value")
        @migration.run
      end

      it "should attempt to save the active record again" do
        @active_record.should_receive(:save!).and_return(true)
        @migration.run
      end

    end

    describe "on a belongs_to or has_one association" do

      before do
        @errors.stub!(:each).and_yield "name", "is invalid"
        @associated_record = mock("asssociated_model", :kind_of? => ActiveRecord::Base,:errors => @errors, :name => "Miller", :name= => "Miller")
        @active_record.stub!(:name).and_return(@associated_record)
      end

      it "should attempt to save the active model" do
        @active_record.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).with(@associated_record, "name", "is invalid").and_return("new_value")
        @migration.run
      end

      it "should attempt to save the active record again" do
        @active_record.should_receive(:save!).and_return(true)
        @migration.run
      end

    end

  end

end
