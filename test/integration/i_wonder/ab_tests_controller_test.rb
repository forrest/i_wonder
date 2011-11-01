require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# This is an integration test because I couldn't get the routes to find the controller on functional tests

module IWonder
  class AbTestsControllerTest < ActionDispatch::IntegrationTest

    # test "index works" do
    #   AbTest.destroy_all
    #   get "i_wonder/ab_tests"
    #   assert_response :success
    # end
    # 
    
    test "update works" do
      AbTest.delete_all
      AbTestGoal.delete_all
      
      @ab_test = Factory(:ab_test)
      @ab_test.ab_test_goals.create(:goal_type => "Event", :event_type => "random event")
      
      goal_1 = @ab_test.ab_test_goals.first
      goal_2 = @ab_test.ab_test_goals.last
      
      
      put "i_wonder/ab_tests/#{@ab_test.id}", {:ab_test => {:name => "new name", :ab_test_goals_attributes => {
          "0" => {:id => goal_1.id, :goal_type => "Event", :event_type => "success 2" },
          "1" => {:id => goal_2.id, :goal_type => "Event", :event_type => "random_event", "_destroy" => true },
          "2" => {:goal_type => "Event", :event_type => "new_event" }
          }}}
      assert_valid assigns(:ab_test)
      @ab_test.reload
      assert_redirected_to @ab_test
      
      # puts "after:"
      #   puts @ab_test.ab_test_goals.collect(&:inspect).join("\n")
      #   
      #   
      assert_equal "new name", @ab_test.name
      assert_equal 2, @ab_test.ab_test_goals.count, @ab_test.ab_test_goals.collect(&:inspect).join("\n")
      assert_equal "success 2", @ab_test.ab_test_goals.first.event_type
      assert_equal "new_event", @ab_test.ab_test_goals.last.event_type
    end

  end
end
