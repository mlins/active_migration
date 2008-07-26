require File.dirname(__FILE__) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/fixtures/product_three_migration'
require File.dirname(__FILE__) + '/fixtures/product_four_migration'

describe "A migration" do

  before do
    @legacy_record = mock('legacy_model', :id => 1, :name => 'Beer')
    @active_record = mock('active_model', :id => 10, :name= => 'Beer', :save => true)
    Product.stub!(:new).and_return(@active_record)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    @file = mock("file", :null_object => true)
    File.stub!(:open).and_yield(@file)
  end

  it "should store key maps in /tmp by default" do
    ActiveMigration::KeyMapper.storage_path.should == "/tmp"
  end

  it "should allow the key maps storage path to be changed" do
    ActiveMigration::KeyMapper.storage_path = "/foo"
    File.should_receive(:open).with(File.join('/foo', 'products_map.yml'), 'w').and_yield(@file)
    ProductThreeMigration.new.run
    ActiveMigration::KeyMapper.storage_path = "/tmp"
  end

  it "should serialize the keys" do
    @file.should_receive(:write).with({1 => 10}.to_yaml)
    ProductThreeMigration.new.run
  end

end

describe "A migration" do

  before do
    @legacy_record = mock('legacy_model', :id => 1, :supplier_id => 1)
    @active_record = mock('active_model', :id => 10, :supplier_id= => 10, :save => true)
    Product.stub!(:new).and_return(@active_record)
    Legacy::Product.stub!(:count).and_return(1)
    Legacy::Product.stub!(:find).and_return([@legacy_record])
    @file = mock("file", :null_object => true)
    File.stub!(:open).and_return(@file)
    @yaml = {1 => 10}
    YAML.stub!(:load).and_return(@yaml)
  end

  it "should open the specified maps" do
    File.should_receive(:open).with(File.join('/tmp', 'products_map.yml')).and_return(@file)
    ProductFourMigration.new.run
  end

  it "should deserialize the specified maps" do
    YAML.should_receive(:load).with(@file)
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