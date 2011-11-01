require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class LoaderTest < ActiveSupport::TestCase
    
    def setup
      AbTest.delete_all
      remove_test_xml_files
    end
    
    def teardown
      remove_test_xml_files
    end
  
    test "Loads Correctly" do
      AbTest.delete_all
      assert_equal 0, AbTest.count
      
      `cp #{TEST_ASSETS + "/i_wonder/save_test.xml"} #{AbTesting::Loader::AB_TEST_DATA_DIR + "/save_test.xml"}`
      
      AbTesting::Loader.load_all
      assert_equal 1, AbTest.count
      @ab_test = AbTest.first
      
      assert_equal "Blah Test", @ab_test.name
      assert_equal "save_test", @ab_test.sym
      assert_equal "Options 1", @ab_test.test_group_names[0]
      assert_equal "Options 2", @ab_test.test_group_names[1]
      assert_equal "session", @ab_test.test_applies_to
      assert_nil @ab_test.test_group_names[3]
      assert_equal 1, @ab_test.ab_test_goals.count
    end
    
    test "Saves Correctly" do
      assert !File.exists?(AbTesting::Loader.send(:file_name, "save_test"))
      
      @ab_test = Factory(:ab_test, :name => "Blah Test", :sym => "save_test")
      AbTesting::Loader.save_ab_test(@ab_test)
      
      assert File.exists?(AbTesting::Loader.send(:file_name, "save_test"))
      
      File.open(AbTesting::Loader.send(:file_name, "save_test")) do |test_created|
        
        File.open(TEST_ASSETS + "/i_wonder/save_test.xml") do |known_result|
          assert_equal known_result.read, test_created.read
        end
      end
    end
    
    test "Updates existing test" do
      @ab_test = Factory(:ab_test, :sym => "save_test")
      `cp #{TEST_ASSETS + "/i_wonder/save_test.xml"} #{AbTesting::Loader::AB_TEST_DATA_DIR + "/save_test.xml"}`
      
      AbTesting::Loader.load_all
      assert_equal 1, AbTest.count
      assert_equal @ab_test, AbTest.first

      @ab_test.reload      
      assert_equal "Blah Test", @ab_test.name
      assert_equal "save_test", @ab_test.sym
      assert_equal "Options 1", @ab_test.test_group_names[0]
      assert_equal "Options 2", @ab_test.test_group_names[1]
      assert_equal "session", @ab_test.test_applies_to
      assert_nil @ab_test.test_group_names[3]
      assert_equal 1, @ab_test.ab_test_goals.count
    end
    
    test "Test Destruction removes files" do
      assert !File.exists?(AbTesting::Loader.send(:file_name, "save_test"))
      @ab_test = Factory(:ab_test, :sym => "save_test")
      assert File.exists?(AbTesting::Loader.send(:file_name, "save_test"))
      @ab_test.destroy
      assert !File.exists?(AbTesting::Loader.send(:file_name, "save_test"))
    end
    
    test "skips saveback when loading" do
      @ab_test = Factory.build(:ab_test, :name => "Blah Test", :sym => "save_test")
      @ab_test.skip_file_save = true
      assert @ab_test.save
      assert_valid @ab_test
      assert !File.exists?(AbTesting::Loader.send(:file_name, "save_test")), "SHould not have saved file"
    end
    
  private
    
    def remove_test_xml_files
      Dir.open(AbTesting::Loader::AB_TEST_DATA_DIR) do |dir|
        dir.each{|file_name|
          if file_name =~ /xml/
            File.delete(AbTesting::Loader::AB_TEST_DATA_DIR + "/"+file_name)
          end
        }
      end
    end
    
  end
end
