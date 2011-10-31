require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

# NOTE: a bunch of the group gathering tests can be found in functional tests because they require chekcing the cookie for the session

module IWonder
  class AbTestTest < ActiveSupport::TestCase
  
    test "counting results" do
      @ab_test = IWonder::AbTest.create(:name => "Unique Test 1", :sym => "unique_sym_1", :test_group_names => ["Options 1", "Options 2"], :ab_test_goals_attributes => {"0" => {:event_type => "success"}}, :test_applies_to => "session")
      assert_valid @ab_test
      ab_test_goal = @ab_test.ab_test_goals.first

      Timecop.travel(Time.zone.now - 1.day) do
        assert IWonder::Event.create(:event_type => "success", :session_id => "5") # this should be ignored
      end

      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "1", :test_group_name => "Option 1")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "2", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "3", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "4", :test_group_name => "Option 2")
      assert @ab_test.test_group_memberships.create(:member_type => "session", :member_id => "5", :test_group_name => "Option 1")
      
      assert IWonder::Event.create(:event_type => "success", :session_id => "1")
      assert IWonder::Event.create(:event_type => "random",  :session_id => "2")
      assert IWonder::Event.create(:event_type => "success", :session_id => "2")
      assert IWonder::Event.create(:event_type => "success", :session_id => "3")
      assert IWonder::Event.create(:event_type => "random",  :session_id => "4")
      assert IWonder::Event.create(:event_type => "success", :session_id => "6")
      
      assert_equal 2, @ab_test.assigned_count("Option 1")
      assert_equal 3, @ab_test.assigned_count("Option 2")
      assert_equal 1, @ab_test.get_results_for("Option 1", ab_test_goal)
      assert_equal 2, @ab_test.get_results_for("Option 2", ab_test_goal)
    end
    
  end
end
