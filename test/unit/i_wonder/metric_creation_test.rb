require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class MetricCreationTest < ActiveSupport::TestCase

    test "Check that dangerous words filtering is working" do
      @metric = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      assert @metric.valid?
      @metric.collection_method = "something.create"
      assert !@metric.valid?
      assert_include @metric.errors.full_messages.join(" "), "create"
      
      
      @metric.collection_method = "where(\"created_at = ?\")"
      assert @metric.valid?      
    end

    test "frequency and takes_snapshots is being set correctly" do
      @metric = Metric.create(:name => "test name")
      assert_valid @metric
      assert !@metric.takes_snapshots?
      assert_equal -1, @metric.frequency
      
      @metric.update_attributes(:takes_snapshots => true, :frequency => 1.hour)
      assert_valid @metric
      assert @metric.takes_snapshots?
      assert_equal 1.hour, @metric.frequency
      
      @metric.update_attributes(:takes_snapshots => false)
      assert !@metric.takes_snapshots?
      assert_equal -1, @metric.frequency
      
      @metric.update_attributes(:takes_snapshots => true, :frequency => 1.hour)
      assert_valid @metric
      
      @metric.update_attributes(:frequency => -1)
      assert_valid @metric
      assert !@metric.takes_snapshots?
      assert_equal -1, @metric.frequency
    end
    
    test "model scope only works for actual models and actual scopes" do
      @metric = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      @metric.collection_type = "model_counter"
      @metric.model_counter_class = "FakeModel"
      assert !@metric.valid?
      
      @metric.model_counter_class = "IWonder::Metric"
      assert_valid @metric
      
      @metric.model_counter_scopes = "fake_scope"
      assert !@metric.valid?
      
      @metric.model_counter_scopes = "archived"
      assert_valid @metric
      
      @metric.model_counter_scopes = "archived.fake_scope"
      assert !@metric.valid?
      
      @metric.model_counter_scopes = "archived.takes_snapshots"
      assert_valid @metric
    end
   
    test "set_event_collection_method works" do
      @metric = Metric.create(:name => "Track Hits", :collection_type => "event_counter", :event_counter_event => "hit")
      Timecop.travel(Time.zone.now - 2.days) do
        Event.create(:event_type => "hit")
      end
      Timecop.travel(Time.zone.now - 2.hours) do
        # This shouldn't make any difference, so why not throw it into the test
        Event.create(:event_type => :hit)
        Event.create(:event_type => "hit")
      end
      
      assert_equal "IWonder::Event.where(:event_type => \"hit\").where(\"created_at >= ? AND created_at < ?\", start_time, end_time).count", @metric.collection_method
      assert_equal 2, @metric.send(:run_collection_method_from, Time.zone.now-1.day, Time.zone.now)
    end
    
    test "set_model_collection_method works (both collection methods) (with and without scopes)" do
      @metric = Metric.create(:name => "Track Accounts", :collection_type => "model_counter", :model_counter_class => "Account")
      Timecop.travel(Time.zone.now - 2.days) do
        Account.create!
      end
      Timecop.travel(Time.zone.now - 2.hours) do
        Account.create!
        Account.create!
      end
      
      assert_equal "Account.where(\"created_at >= ? AND created_at < ?\", start_time, end_time).count", @metric.collection_method
      assert_equal 2, @metric.send(:run_collection_method_from, Time.zone.now-1.day, Time.zone.now)
      assert_equal "sum", @metric.combination_rule

      @metric.update_attributes(:model_counter_method => "Total Number")
      assert_equal "average", @metric.combination_rule
      
      assert_equal "Account.where(\"created_at < ?\", end_time).count", @metric.collection_method
      assert_equal 3, @metric.send(:run_collection_method_from, Time.zone.now-1.day, Time.zone.now)
      
      @metric.update_attributes(:model_counter_scopes => ".archived")
      assert_equal "Account.archived.where(\"created_at < ?\", end_time).count", @metric.collection_method
      
      @metric.update_attributes(:model_counter_scopes => "archived")
      assert_equal "Account.archived.where(\"created_at < ?\", end_time).count", @metric.collection_method
    end
    
  end
end
