require File.dirname(__FILE__) + '/spec_helper.rb'

#require 'rubygems'; require 'ruby-debug'

describe "A migration" do

  before do
    @migration = ProductMigration.new
    @legacy_model = mock("ar_object1", :null_object => true)
    @active_model = mock("ar_object2", :null_object => true)
    @legacy_model.stub!(:name).and_return("Beer")
    @active_model.stub!(:name=).and_return("Beer")
    Product.stub!(:new).and_return(@active_model)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_model])
  end

  it "should not run in batches" do
    @migration.should_not_receive(:run_in_batches)
    @migration.run
  end

  it "should run normal" do
    @migration.should_receive(:run_normal)
    @migration.run
  end

  it "should create a new active model" do
    Product.should_receive(:new).and_return(@active_model)
    @migration.run
  end

  it "should find the legacy records" do
    Legacy::Product.should_receive(:find).and_return(@legacy_model)
    @migration.run
  end

  it "should get the legacy name value" do
    @legacy_model.should_receive(:name).and_return("Beer")
    @migration.run
  end

  it "should set the active name value to the legcy value" do
    @active_model.should_receive(:name=).with("Beer").and_return("Beer")
    @migration.run
  end

  describe "without validation errors" do

    before do
      @active_model.stub!(:save).and_return(true)
    end

    it "should attempt to save the active model" do
      @active_model.should_receive(:save).and_return(true)
      @migration.run
    end

    it "should call #handle_success" do
      @migration.should_receive(:handle_success).with(@active_model, "name")
      @migration.run
    end

  end

  describe "with validation errors" do

    before do
      @errors = mock('errors_object', :null_object => true)
      @active_model.stub!(:save).and_return(false)
      @active_model.stub!(:valid?).and_return(false, true)
      @active_model.stub!(:errors).and_return(@errors)
      @migration.stub!(:handle_error).and_return("new_value")
    end

    describe "on one field" do

      before do
        @errors.stub!(:each).and_yield "name", "has an error"
      end

      it "should attempt to save the active model" do
        @active_model.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).with(@active_model, "name", "name", "has an error").and_return("new_value")
        @migration.run
      end

    end

    describe "on a has_many association" do

      before do
        @errors.stub!(:each).and_yield "name", "is invalid"
        @associated_model = mock("ar_object3", :null_object => true)
        @associated_model.stub!(:errors).and_return(@errors)
        @active_model.stub!(:name).and_return([@associated_model, @associated_model])
      end

      it "should attempt to save the active model" do
        @active_model.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).exactly(2).with(@associated_model, "name", "name", "is invalid").and_return("new_value")
        @migration.run
      end

    end

    describe "on a belongs_to or has_one association" do

      before do
        @errors.stub!(:each).and_yield "name", "is invalid"
        @associated_model = mock("ar_object4", :null_object => true)
        @associated_model.stub!(:errors).and_return(@errors)
        @associated_model.stub!(:kind_of?).and_return(ActiveRecord::Base)
        @associated_model.stub!(:name).and_return("Beer")
        @active_model.stub!(:name).and_return(@associated_model)
      end

      it "should attempt to save the active model" do
        @active_model.should_receive(:save).and_return(false)
        @migration.run
      end

      it "should call #handle_error" do
        @migration.should_receive(:handle_error).with(@associated_model, "name", "name", "is invalid").and_return("new_value")
        @migration.run
      end

    end

  end

end
