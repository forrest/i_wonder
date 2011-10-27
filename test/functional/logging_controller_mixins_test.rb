require File.expand_path("../test_helper.rb", File.dirname(__FILE__))

class LoggingControllerMixinsTest < ActionController::TestCase
  tests TestController

  test "setting user and account" do
    session[:user_credentials_id] = 1
    get :test_without_report
    
    assert @request.env["i_wonder"]
    assert_equal "2", @request.env["i_wonder"]["user_id"]
    assert_equal "3", @request.env["i_wonder"]["account_id"]
  end
  
  
  test "reporting an event" do
    get :test_with_report
    
    assert @request.env["i_wonder"]["new_events"]
    assert_equal 1, @request.env["i_wonder"]["new_events"].length
    assert_equal "test_event", @request.env["i_wonder"]["new_events"].first[:event_type]
  end
  
end
