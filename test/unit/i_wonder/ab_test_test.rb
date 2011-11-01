require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# NOTE: a bunch of the group gathering tests can be found in functional tests because they require chekcing the cookie for the session

module IWonder
  class AbTestTest < ActiveSupport::TestCase
  
    test "counting results" do
      AbTest.delete_all
      
      @ab_test = Factory(:ab_test)
      @ab_test.ab_test_goals.create(:goal_type => "Page View", :page_view_controller => "TestController", :page_view_action => "test")
      assert_valid @ab_test
      ab_test_goal_1 = @ab_test.ab_test_goals[0]
      ab_test_goal_2 = @ab_test.ab_test_goals[1]
      assert_equal "test", ab_test_goal_2.page_view_controller

      Timecop.travel(Time.zone.now - 1.day) do
        assert Event.create(:event_type => "success", :session_id => "5") # this should be ignored
      end

      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "1", :test_group_name => "Option 1")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "2", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "3", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "4", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "5", :test_group_name => "Option 1")
      
      assert Event.create(:event_type => "success", :session_id => "1")
      assert Event.create(:event_type => "success", :session_id => "1") # duplicate shouldn't be counted
      assert Event.create(:event_type => "hit",     :session_id => "1", :controller => "test", :action => "test")
      assert Event.create(:event_type => "random",  :session_id => "2")
      assert Event.create(:event_type => "success", :session_id => "2")
      assert Event.create(:event_type => "success", :session_id => "3")
      assert Event.create(:event_type => "random",  :session_id => "4")
      assert Event.create(:event_type => "success", :session_id => "6")
      
      assert_equal 2, @ab_test.assigned_count("Option 1")
      assert_equal 3, @ab_test.assigned_count("Option 2")
      assert_equal 1, @ab_test.get_results_for("Option 1", ab_test_goal_1)
      assert_equal 2, @ab_test.get_results_for("Option 2", ab_test_goal_1)
      
      assert_equal 1, @ab_test.get_results_for("Option 1", ab_test_goal_2)
    end
    
  end
end
