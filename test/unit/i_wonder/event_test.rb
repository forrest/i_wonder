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
    
    
  end
end
