require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# This is an integration test because I couldn't get the routes to find the controller on functional tests

module IWonder
  class DashboardControllerTest < ActionDispatch::IntegrationTest

    # The before_Filter is in the dummy application
    test "before_filter security from main_app" do
      get "/i_wonder"
      assert_response :success
      
      get "/i_wonder", :block_this => true
      assert_redirected_to "/"
    end

  end
end
