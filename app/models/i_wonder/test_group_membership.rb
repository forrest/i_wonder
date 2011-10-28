module IWonder
  class TestGroupMembership < ActiveRecord::Base
    belongs_to :ab_test
    
    validates_presence_of :test_group_name, :on => :create, :message => "can't be blank"
    validates_inclusion_of :member_type, :in => %w( account user session ), :on => :create
    validates_presence_of :member_id, :on => :create, :message => "can't be blank"
    
    validates_uniqueness_of :ab_test_id, :on => :create, :message => "must be unique for this member", :scope => [:member_type, :member_id]
    
  end
end
