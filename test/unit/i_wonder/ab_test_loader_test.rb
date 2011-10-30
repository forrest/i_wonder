require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class LoaderTest < ActiveSupport::TestCase
    
    def setup
      AbTesting::Loader.const_set :I_WONDER_DATA_DIR, TEST_ASSETS + "/i_wonder"
    end
  
    test "Loads" do
      assert_equal TEST_ASSETS+"/i_wonder", AbTesting::Loader::I_WONDER_DATA_DIR
      
      AbTest.delete_all
      assert_equal 0, AbTest.count
      
      # AbTesting::Loader.load_all
      assert_equal 1, AbTest.count
    end
    
    test "Saves and loads Correctly" do
      remove_test_xml_file
      
      # create ab_test
      # save test to file
      # confirm that the file is there
      # read the file and confirm the xml matches what we expect
      
      remove_test_xml_file
      pending
    end
    
  private
    
    def remove_test_xml_file
      # destroy file with proper symbol if it exists
    end
    
  end
end
