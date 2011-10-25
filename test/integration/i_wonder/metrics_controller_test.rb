require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# This is an integration test because I couldn't get the routes to find the controller on functional tests

module IWonder
  class MetricsControllerTest < ActionDispatch::IntegrationTest
    
    test "creating new metric" do
      post "i_wonder/metrics", :i_wonder_metric => {:name => "New Metric"}
      metric = assigns(:metric)
      assert_valid metric
      assert_redirected_to metric
      
      assert_equal "New Metric", metric.name
    end
    
  end
end
