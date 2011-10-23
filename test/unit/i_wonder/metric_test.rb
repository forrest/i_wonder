require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class MetricTest < ActiveSupport::TestCase

    test "Checking the scope for metrics requiring updates" do
      IWonder::Metric.delete_all
      @m1 = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      @m2 = Factory(:metric, :frequency => 1.hour, :last_measurement => Time.now - 30.minutes)
      @m3 = Factory(:metric, :frequency => 1.hour, :last_measurement => Time.now - 90.minutes)
      @m4 = Factory(:metric, :frequency => 1.day, :last_measurement => Time.now - 90.minutes)
      @m5 = Factory(:metric, :frequency => 1.day, :last_measurement => Time.now - 2.days)
      @m6 = Factory(:metric, :frequency => -1, :last_measurement => nil)


      assert_equal 3, IWonder::Metric.needs_to_be_measured.count
      assert_include IWonder::Metric.needs_to_be_measured, @m1
      assert_include IWonder::Metric.needs_to_be_measured, @m3
      assert_include IWonder::Metric.needs_to_be_measured, @m5
    end

    test "Check that the metric method doesn't like dangerous works" do
      @metric = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      assert @metric.valid?
      @metric.collection_method = "save"
      assert !@metric.valid?

      assert_include @metric.errors.full_messages.join(" "), "save"
    end

    test "Check that the metric method is sandboxed in the transaction" do
      IWonder::Metric.destroy_all
      @report = Factory(:report)

      @metric = Factory(:metric)
      @metric.instance_eval do
        def avoid_dangerous_words
          true
        end
      end    
      @metric.collection_method = "IWonder::Report.find(#{@report.id}).destroy; 1"
      @metric.save
      assert @metric.valid?

      IWonder::Metric.take_measurements
      @metric.reload

      assert IWonder::Report.exists?(@report.id)
      assert_equal 1, @metric.snapshots.count
    end

  end
end
