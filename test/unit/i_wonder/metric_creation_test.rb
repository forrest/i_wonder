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

    test "model scope only works for actual models and actual scopes" do
      @metric = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      @metric.collection_type = "model_counter"
      @metric.model_counter_class = "FakeModel"
      assert !@metric.valid?
      
      @metric.model_counter_class = "IWonder::Metric"
      assert @metric.valid?
      
      @metric.model_counter_scopes = "fake_scope"
      assert !@metric.valid?
      
      @metric.model_counter_scopes = "archived"
      assert @metric.valid?
      
      @metric.model_counter_scopes = "archived.fake_scope"
      assert !@metric.valid?
      
      @metric.model_counter_scopes = "archived.takes_snapshots"
      assert @metric.valid?
    end
    
  end
end
