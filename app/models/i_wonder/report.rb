module IWonder
  class Report < ActiveRecord::Base
    set_table_name "i_wonder_reports"
    
    attr_accessible :name, :description, :report_type, :metric_ids

    validates_length_of :name, :within => 1..250
    validates_uniqueness_of :name, :message => "must be unique"

    has_many :report_memberships
    has_many :metrics, :through => :report_memberships
    accepts_nested_attributes_for :report_memberships, :allow_destroy => true

    def line?
      report_type =~ /line/i
    end
    def bar?
      report_type =~ /bar/i
    end
    def pie?
      report_type =~ /pie/i
    end
    def test?
      report_type =~ /test/i
    end
    
    def metric_ids=(new_metric_ids)
      self.report_memberships.each(&:mark_for_destruction)
      
      new_metric_ids.uniq.each{|metric_id|
        self.report_memberships.build(:metric_id => metric_id)
      }
    end
    
    def metric_ids
      self.metrics.collect(&:ids)
    end
    
    
    def collect_series_data(start_time = nil, end_time = nil, interval_length = nil)
      if line?
        collect_line_series(start_time, end_time, interval_length)
      end
    end
    
  private
  
    def collect_line_series(start_time, end_time, interval_length)
      if end_time < start_time
        raise "Can't work backwards"
      end

      if interval_length <= 0
        raise "Need a real interval"
      end

      master_hashes_array = []
      keys_list = []
      time_iterator = start_time
      begin
        master_hash_for_time_slice = {}
        
        self.metrics.each{|m|
          master_hash_for_time_slice.merge!(m.value_from(time_iterator, time_iterator + interval_length))
        }
        
        keys_list += master_hash_for_time_slice.keys
        keys_list.uniq!
        master_hashes_array << master_hash_for_time_slice
        
        time_iterator += interval_length
      end while time_iterator <= end_time

      # set the value to zero for any
      master_hashes_array.each{|hash_for_slice_of_time|
        keys_list.each{|key|
          hash_for_slice_of_time[key] ||= 0
        }
      }
      
      keys_list.collect{|key|
        {:name => key, :pointInterval => interval_length*1000, :data => master_hashes_array.collect{|mha| mha[key] }}
      }
    end

  end
end
