require File.expand_path("../test_helper.rb", File.dirname(__FILE__))

class ConfigurationTest < ActiveSupport::TestCase
  test "did the initializer get loaded" do
    assert_equal 2.weeks, IWonder.configuration.keep_hits_for
    
    IWonder.configure do |c|
      c.keep_hits_for = 4.weeks
    end
    
    assert_equal 4.weeks, IWonder.configuration.keep_hits_for    
  end
end