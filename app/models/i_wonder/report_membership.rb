module IWonder
  class ReportMembership < ActiveRecord::Base
    set_table_name "i_wonder_report_memberships"
    
    belongs_to :report
    belongs_to :metric
  end
end
