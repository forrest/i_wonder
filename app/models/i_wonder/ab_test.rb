module IWonder
  class AbTest < ActiveRecord::Base
    attr_accessible :name, :sym, :description
    
    serialize :options, Hash
    serialize :test_group_data, Hash
    
    # has_many :test_group_memberships
  end
end
