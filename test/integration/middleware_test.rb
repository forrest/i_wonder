require File.expand_path("../test_helper.rb", File.dirname(__FILE__))

class MiddlewareTest < ActionDispatch::IntegrationTest
  
  test "Is the hit logged correctly" do
    assert_nil cookies["i_wonder_session_id"]    
    IWonder::Event.destroy_all
    assert cookies["i_wonder_session_id"].blank?
    
    get "/test_without_report", {}, {"HTTP_REFERER" => 'http://google.com', "User-Agent" => 'chrome' }
    
    assert_equal 2, IWonder::Event.count
    assert_equal "new_visitor", IWonder::Event.first.event_type
    assert_equal "hit", IWonder::Event.last.event_type
    assert_equal "test", IWonder::Event.first.controller
    assert_equal "test_without_report", IWonder::Event.first.action
    
    
    assert_equal "127.0.0.1", IWonder::Event.first.remote_ip
    assert_equal "http://google.com", IWonder::Event.first.referrer
    assert_equal "chrome", IWonder::Event.first.user_agent
    
    assert cookies["i_wonder_session_id"].present?
    assert_equal cookies["i_wonder_session_id"], IWonder::Event.first.session_id
    original_session_key = cookies["i_wonder_session_id"]
    
    get "/test_without_report"
    assert_equal 3, IWonder::Event.count
    assert_equal "hit", IWonder::Event.last.event_type    
    assert_equal original_session_key, IWonder::Event.last.session_id, "Session should not have changed"
  end
  
  test "when user is added previous events get merged" do
    IWonder::Event.destroy_all
    get "/test_without_login"
    assert_equal 2, IWonder::Event.count
    assert cookies["i_wonder_no_user"], "Should have flagged no_user"
    assert_nil IWonder::Event.first.user_id, "Should not have a user set"
    
    get "/test_without_report"
    assert_equal 3, IWonder::Event.count
    assert_equal 2, IWonder::Event.last.user_id, "User should have been added"
    assert_blank cookies["i_wonder_no_user"], "Should have removed the no_user flag"
    
    
    IWonder::Event.fast_create(:event_type => "blah blah")
    
    assert_equal IWonder::Event.all[2].user_id, IWonder::Event.all[0].user_id, "Should have updated user"
    assert_blank IWonder::Event.last.user_id
  end
  
  test "ignores bot" do
    IWonder::Event.destroy_all
    get "/test_without_login", {}, {"User-Agent" => 'yahoo'}
    assert_equal 0, IWonder::Event.count
  end
  
  test "ignores non-200 status with default configuration" do
    IWonder::Event.destroy_all
    get "/test_redirect"
    assert_response 302
    assert_equal 0, IWonder::Event.count
  end
  
  test "logges non-200 status with custom configuration" do
    IWonder::Event.destroy_all
    
    IWonder.configure do |c|
      c.only_log_hits_on_200 = false
    end
    
    get "/test_redirect"
    assert_response 302
    assert_equal 2, IWonder::Event.count
    
    IWonder.configure do |c|
      c.only_log_hits_on_200 = true
    end
  end
  
  test "ignores controller in do_no_log list" do
    IWonder::Event.destroy_all
    get "i_wonder/events"
    assert_response :success
    assert_equal 0, IWonder::Event.count
  end
  
  test "return_visit_gets set correctly" do
    IWonder::Event.destroy_all
    
    Timecop.travel(Time.zone.now - 3.hours) do
      get "/test_without_report"
      assert_equal 2, IWonder::Event.count
      
      get "/test_without_report"
      assert_equal 3, IWonder::Event.count
    end
    
    get "/test_without_report"
    assert_equal 5, IWonder::Event.count
    
    assert_include IWonder::Event.all.collect(&:event_type), "return_visit"
  end
  
  test "trims down events to avoid errors" do
    IWonder::Event.destroy_all
    get "/test_without_report", {}, {"HTTP_REFERER" => 'http://google.com?test='+(0..500).to_a.join() }
    
    assert_equal 2, IWonder::Event.count
  end
  
end