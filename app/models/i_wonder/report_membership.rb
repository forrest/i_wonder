module IWonder
  class ReportMembership < ActiveRecord::Base
    belongs_to :report
    belongs_to :metric
  end
end
