require File.expand_path("../../test_helper.rb", File.dirname(__FILE__))

module IWonder
  class ReportTest < ActiveSupport::TestCase
    
    test "gathering series data for a line chart" do
      Timecop.freeze(2012, 10, 24) do      
        @metric_1 = Factory(:metric, :name => "Test Metric 1", :frequency => 1.day)
        @snapshot_11 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.now - 2.days, :data => 1)
        @snapshot_12 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.now - 1.days, :data => 2)
        @snapshot_13 = Factory(:snapshot, :metric => @metric_1, :created_at => Time.now, :data => 3)
      
        @metric_2 = Factory(:metric, :name => "Test Metric 2", :frequency => 1.day)
        @snapshot_22 = Factory(:snapshot, :metric => @metric_2, :created_at => Time.now - 1.days, :count => nil, :data => {"key_1" => 3, "key_2" => 1})
        @snapshot_23 = Factory(:snapshot, :metric => @metric_2, :created_at => Time.now, :count => nil, :data => {"key_1" => 3, "key_2" => 2})
        
        @report = Factory(:report, :report_type => "line", :metric_ids => [@metric_1.id, @metric_2.id])
        assert_equal 2, @report.metrics.count
      
        series_data = @report.send :collect_series_data, Time.now - 2.days, Time.now, 1.day
        
        proper_results = [
                          {:name=>"Test Metric 1", :pointInterval=>86400000, :data=>[1.0, 2.0, 3.0]}, 
                          {:name=>"key_1", :pointInterval=>86400000, :data=>[0.0, 3.0, 3.0]}, 
                          {:name=>"key_2", :pointInterval=>86400000, :data=>[0.0, 1.0, 2.0]}
        ]
        
        assert_equal proper_results, series_data
      end
    end
    
  end
end
