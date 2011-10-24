require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class MetricCollectionTest < ActiveSupport::TestCase

    test "scope for metrics requiring updates" do
      IWonder::Metric.delete_all
      @m1 = Factory(:metric, :frequency => 1.hour, :last_measurement => nil)
      @m2 = Factory(:metric, :frequency => 1.hour, :last_measurement => Time.now - 30.minutes)
      @m3 = Factory(:metric, :frequency => 1.hour, :last_measurement => Time.now - 90.minutes)
      @m4 = Factory(:metric, :frequency => 1.day, :last_measurement => Time.now - 90.minutes)
      @m5 = Factory(:metric, :frequency => 1.day, :last_measurement => Time.now - 2.days)
      @m6 = Factory(:metric, :frequency => -1, :last_measurement => nil)
      @m7 = Factory(:metric, :frequency => 1.hour, :last_measurement => nil, :archived => true)

      assert_equal 3, IWonder::Metric.needs_to_be_measured.count
      assert_include IWonder::Metric.needs_to_be_measured, @m1
      assert_include IWonder::Metric.needs_to_be_measured, @m3
      assert_include IWonder::Metric.needs_to_be_measured, @m5
    end

    test "metric method is sandboxed in the transaction" do
      IWonder::Metric.destroy_all
      @report = Factory(:report)

      @metric = Factory(:metric, :collection_type => "custom")
      @metric.instance_eval do
        def avoid_dangerous_words
          true
        end
      end    
      @metric.collection_method = "IWonder::Report.find(#{@report.id}).destroy; 1"
      @metric.save
      assert @metric.valid?

      @metric.take_snapshot
      @metric.reload

      assert IWonder::Report.exists?(@report.id)
      assert_equal 1, @metric.snapshots.count
    end

    test "grabbing most recent snapshot and calculating time range" do
      Timecop.freeze(2012, 10, 24) do
      
        @metric_1 = Factory(:metric, :frequency => 1.day)
        @metric_2 = Factory(:metric, :frequency => 1.day)
      
        @snapshot_1 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 4.days)
        @snapshot_2 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 3.days)
        @snapshot_3 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 2.days)
      
        assert_equal @snapshot_3, @metric_1.snapshots.most_recent
        assert_nil @metric_2.snapshots.most_recent
        assert_equal [Time.zone.now - 2.day, Time.zone.now - 1.day], @metric_1.timeframe_for_next_snapshot, "Not calculating times from snapshot correctly"
        assert_equal [Time.zone.now - 1.day, Time.zone.now], @metric_2.timeframe_for_next_snapshot, "Not calculating times without snapshot correctly"
      end
    end
    
    test "grabbing values from snapshots in timerange (integers)" do
      Timecop.freeze(2012, 10, 24) do      
        @metric_1 = Factory(:metric, :name => "Test Metric", :frequency => 1.day)
        @snapshot_1 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 5.days, :data => 1)
        @snapshot_2 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 4.days, :data => 2)
        @snapshot_3 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 3.days, :data => 3)
        @snapshot_4 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 2.days, :data => 4)
        @snapshot_5 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 1.days, :data => 5)
        
        
        res = @metric_1.value_from(Time.zone.now - 4.days, Time.zone.now - 2.days + 1.second)
        assert res.eql?({"Test Metric" => 9.0})
      end
    end
    
    test "grabbing values from snapshots in timerange (hashes)" do
      Timecop.freeze(2012, 10, 24) do      
        @metric_1 = Factory(:metric, :name => "Test Metric", :frequency => 1.day)
        @snapshot_1 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 5.days, :count => nil, :data => {"key_1" => 1})
        @snapshot_2 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 4.days, :count => nil, :data => {"key_1" => 2})
        @snapshot_3 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 3.days, :count => nil, :data => {"key_1" => 3, "key_2" => 1})
        @snapshot_4 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 2.days, :count => nil, :data => {"key_1" => 4, "key_2" => 2})
        @snapshot_5 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 1.days, :count => nil, :data => {"key_1" => 5, "key_2" => 3})
        
        
        res = @metric_1.value_from(Time.zone.now - 4.days, Time.zone.now - 2.days + 1.second)
        assert res.eql?({"key_1" => 9.0, "key_2" => 3.0})
      end
    end
    
    test "grabbing values from no-snapshot collection_method" do
      Timecop.freeze(2012, 10, 24) do      
        @metric_1 = Factory(:metric, :name => "Test Metric", :frequency => -1, :collection_method => "3")
        res = @metric_1.value_from(Time.zone.now - 4.days, Time.zone.now - 2.days + 1.second)
        assert res.eql?({"Test Metric" => 3.0})
      end
    end
    
    test "merging snapshot methods (sumation vs averaging)" do
      
      Timecop.freeze(2012, 10, 24) do      
        # with the default summation set
        @metric_1 = Factory(:metric, :name => "Test Metric", :frequency => 1.day)
        @snapshot_1 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 2.days, :data => 1)
        @snapshot_2 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 1.days, :data => 3)
        res = @metric_1.value_from(Time.zone.now - 2.days, Time.zone.now - 1.day + 1.second)
        assert res.eql?({"Test Metric" => 4.0})

        # with the default summation set
        @metric_1.combination_rule = "average"
        @metric_1.save
      
        @snapshot_1 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 2.days, :data => 1)
        @snapshot_2 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.zone.now - 1.days, :data => 3)
        res = @metric_1.value_from(Time.zone.now - 2.days, Time.zone.now)
        assert res.eql?({"Test Metric" => 2.0})
      end
    end

  end
end
