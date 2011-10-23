require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# This is an integration test because I couldn't get the routes to find the controller on functional tests

module IWonder
  class EventsControllerTest < ActionDispatch::IntegrationTest

    test "index works" do
      get "i_wonder/events"
      assert_response :success
    end

  end
end
