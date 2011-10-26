require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class ReportTest < ActiveSupport::TestCase
    
    test "gathering series data for a line chart" do
      Timecop.freeze(2012, 10, 24) do      
        @metric_1 = Factory(:metric, :name => "Test Metric 1", :frequency => 1.day)
        @snapshot_11 = Factory(:snapshot, :metric => @metric_1, :start_time => Time.zone.now - 3.days, :end_time => Time.zone.now - 2.days, :data => 1)
        @snapshot_12 = Factory(:snapshot, :metric => @metric_1, :start_time => Time.zone.now - 2.days, :end_time => Time.zone.now - 1.days, :data => 2)
        @snapshot_13 = Factory(:snapshot, :metric => @metric_1, :start_time => Time.zone.now - 1.day, :end_time => Time.zone.now, :data => 3)
      
        @metric_2 = Factory(:metric, :name => "Test Metric 2", :frequency => 1.day)
        @snapshot_22 = Factory(:snapshot, :metric => @metric_2, :start_time => Time.zone.now - 2.days, :end_time => Time.zone.now - 1.days, :count => nil, :data => {"key_1" => 3, "key_2" => 1})
        @snapshot_23 = Factory(:snapshot, :metric => @metric_2, :start_time => Time.zone.now - 1.days, :end_time => Time.zone.now, :count => nil, :data => {"key_1" => 3, "key_2" => 2})
        
        @report = Factory(:report, :report_type => "line", :metric_ids => [@metric_1.id, @metric_2.id])
        assert_equal 2, @report.metrics.count
      
        series_data = @report.send :collect_series_data, Time.zone.now - 3.days, Time.zone.now, 1.day
        
        proper_results = [
                          {:name=>"Test Metric 1",  :pointStart => (Time.zone.now - 3.days).to_i*1000, :pointInterval=>1.day*1000, :data=>[1.0, 2.0, 3.0]}, 
                          {:name=>"key_1",          :pointStart => (Time.zone.now - 3.days).to_i*1000, :pointInterval=>1.day*1000, :data=>[0.0, 3.0, 3.0]}, 
                          {:name=>"key_2",          :pointStart => (Time.zone.now - 3.days).to_i*1000, :pointInterval=>1.day*1000, :data=>[0.0, 1.0, 2.0]}
        ]
        
        assert_equal proper_results, series_data
      end
    end
    
  end
end
