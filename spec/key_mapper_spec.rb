require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_three_migration'
require File.dirname(__FILE__) + '/fixtures/product_four_migration'

describe "A migration" do

  before do
    ActiveMigration::Base.logger = mock('logger', :null_object => true)
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :id => 10, :name= => 'Beer', :save => true)
    @active_record.stub!(:changed?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    @file = mock("file", :null_object => true)
    File.stub!(:open).and_yield(@file)
  end

  it "should store key maps in /tmp by default" do
    ActiveMigration::KeyMapper.storage_path.should == "/tmp"
  end

  it "should allow the key maps storage path to be changed" do
    ActiveMigration::KeyMapper.storage_path = "/foo"
    File.should_receive(:open).with(File.join('/foo', 'product_three_migration_map.yml'), 'w').and_yield(@file)
    ProductThreeMigration.new.run
    ActiveMigration::KeyMapper.storage_path = "/tmp"
  end

  it "should serialize the keys" do
    @file.should_receive(:write).with({1 => 10}.to_yaml)
    ProductThreeMigration.new.run
  end

end

describe "A migration with model that has a composite primary key" do

  before do
    ActiveMigration::Base.logger = mock('logger', :null_object => true)
    @legacy_record = mock('legacy_model', :id => [1,2], :name => 'Beer')
    @active_record = mock('active_model', :id => 10, :name= => 'Beer', :save => true)
    @active_record.stub!(:changed?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    @file = mock("file", :null_object => true)
    File.stub!(:open).and_yield(@file)
  end

  it "should store key maps in /tmp by default" do
    ActiveMigration::KeyMapper.storage_path.should == "/tmp"
  end

  it "should allow the key maps storage path to be changed" do
    ActiveMigration::KeyMapper.storage_path = "/foo"
    File.should_receive(:open).with(File.join('/foo', 'product_three_migration_map.yml'), 'w').and_yield(@file)
    ProductThreeMigration.new.run
    ActiveMigration::KeyMapper.storage_path = "/tmp"
  end

  it "should serialize the keys" do
    @file.should_receive(:write).with({'1_2' => 10}.to_yaml)
    ProductThreeMigration.new.run
  end

end

describe "A migration" do

  before do
    @legacy_record = mock('legacy_model', :id => 1, :supplier_id => 1, :supplier_id= => 10)
    @active_record = mock('active_model', :id => 10, :supplier_id= => 10, :save => true)
    @active_record.stub!(:changed?).and_return(true,false)
    Product.stub!(:new).and_return(@active_record)
    Product.stub!(:table_name).and_return('some_new_table')
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    Legacy::Product.stub!(:table_name).and_return('some_old_table')
    @file = mock("file", :null_object => true)
    File.stub!(:open).and_return(@file)
    File.stub!(:file?).and_return(true)
    @yaml = {1 => 10}
    YAML.stub!(:load).and_return(@yaml)
  end

  it "should open the specified maps" do
    File.should_receive(:open).with(File.join('/tmp', 'products_map.yml')).and_return(@file)
    ProductFourMigration.new.run
  end

  it "should deserialize the specified maps" do
    YAML.should_receive(:load).with(@file).and_return(@yaml)
    ProductFourMigration.new.run
  end

  it "should set the legacy_model to the new value before the field is migrated" do
    @legacy_record.should_receive(:supplier_id=).with(10).and_return(10)
    ProductFourMigration.new.run
  end

  it "should set the legacy_model to the old value after the field is migrated" do
    @legacy_record.should_receive(:supplier_id=).with(1).and_return(1)
    ProductFourMigration.new.run
  end

  describe "#mapped_key" do

    it 'should return the mapped key' do
      p = ProductFourMigration.new
      p.run
      p.send(:mapped_key, :products, 1).should == 10
    end

  end

end