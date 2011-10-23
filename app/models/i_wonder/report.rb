module IWonder
  class Report < ActiveRecord::Base
     attr_accessible :name, :description, :report_type

      validates_length_of :name, :within => 1..250
      validates_uniqueness_of :name, :message => "must be unique"

      has_many :report_memberships
      has_many :metrics, :through => :report_memberships
  end
end
