module IWonder
  class ReportMembership < ActiveRecord::Base
    belongs_to :report#, :foreign_key => "i_wonder_report_id"
    belongs_to :metric#, :foreign_key => "i_wonder_metric_id"
  end
end
