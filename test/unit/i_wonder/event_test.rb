require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

class TestModel
  include IWonder::Logging::ActiveRecordMixins
end


module IWonder
  class EventTest < ActiveSupport::TestCase
    
    test "logging event from class method" do
      original_count = Event.count
      TestModel.send :report!, :test_event
      assert_equal original_count+1, Event.count
    end

    test "logging event from instance method" do
      original_count = Event.count
      TestModel.new.send :report!, :test_event
      assert_equal original_count+1, Event.count
      assert_equal "test_event", Event.first.event_type
    end
    
    test "Event.groups & Event.get_details_for_event_type()" do
      TestModel.new.send :report!, "test_event_1"
      TestModel.new.send :report!, "test_event_1"
      TestModel.new.send :report!, "test_event_2"
      TestModel.new.send :report!, "test_event_3"
      TestModel.new.send :report!, "test_event_1"
      
      groups = Event.groups
      assert_equal 3, groups.length
      
      group_1 = groups[0]
      group_2 = groups[1]
      group_3 = groups[2]
      
      assert_equal "test_event_1", group_1[:event_type]
      assert_equal "test_event_3", group_2[:event_type]
      assert_equal "test_event_2", group_3[:event_type]
      
      assert_equal 3, group_1[:count]
      assert_equal 1, group_2[:count]
      assert_equal 1, group_3[:count]
      
      #TODO: check the most recent at times
      
      details = Event.get_details_for_event_type("test_event_1")
      assert_equal "test_event_1", details[:event_type]
      assert_equal 3, details[:count]
      
    end
    
    test "merging events to a user" do
      Event.delete_all
      
      Timecop.travel(Time.zone.now - 30.days) do
        @e11 = Event.create :event_type => "new_visitor", :session_id => "123"
        @e12 = Event.create :event_type => "hit", :session_id => "123"
        @e13 = Event.create :event_type => "hit", :session_id => "123", :user_id => "1"
        
        Event.merge_session_to_user("123", "1")
        
        assert_equal 3, Event.where(:user_id => "1").count
        assert_equal 3, Event.where(:session_id => "123").count
        assert_equal 1, Event.where(:session_id => "123", :user_id => "1", :event_type => "new_visitor").count
      end
      
      @e21 = Event.create :event_type => "new_visitor", :session_id => "321"
      @e22 = Event.create :event_type => "hit", :session_id => "321"
      Event.merge_session_to_user("321", "1")
      
      assert_equal 4, Event.where(:session_id => "123").count
      assert_equal 1, Event.where(:session_id => "123", :event_type => "new_visitor").count
      assert_equal 0, Event.where(:session_id => "321").count
      assert_equal 4, Event.where(:user_id => "1").count
      
    end
    
  end
end
