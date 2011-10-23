module IWonder
  class Report < ActiveRecord::Base
     attr_accessible :name, :description, :report_type, :min_start, :max_end, :clean_min_start, :clean_max_end, :metrics_attributes

      validates_length_of :name, :within => 1..250
      validates_uniqueness_of :name, :message => "must be unique"

      has_many :metrics, :through => :report_membership

      def clean_min_start
        (min_start.present? ? min_start : Time.zone.now).strftime("%Y/%m/%d")
      end
      def clean_min_start=(new_date)
        self.min_start = new_date
      end
      def clean_max_end
        max_end.present? ? max_end.strftime("%Y/%m/%d") : ""
      end
      def clean_max_end=(new_date)
        self.max_end = new_date
      end
  end
end
