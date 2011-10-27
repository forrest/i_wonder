module IWonder
  class AbTest < ActiveRecord::Base
    attr_accessible :name, :sym, :description, :ab_test_goals_attributes, :test_applies_to, :test_group_names
    serialize :options, Hash
    serialize :test_group_data, Hash
    
    has_many :test_group_memberships, :dependent => :destroy

    has_many :ab_test_goals, :dependent => :destroy
    accepts_nested_attributes_for :ab_test_goals, :allow_destroy => true
    
    hash_accessor :options, :test_group_names, :type => :array, :reject_blanks => true
    
    validates_presence_of :name, :on => :create, :message => "can't be blank"
    validates_presence_of :sym, :on => :create, :message => "can't be blank"
    validates_format_of :sym, :with => /^[\w\d\_]+$/, :on => :create, :message => "can only contain letters, numbers and underscores"
    
    validate :has_two_groups_and_a_goal
    def has_two_groups_and_a_goal
      unless test_group_names.length >= 2
        errors.add(:base, "Must have atleast two test groups")
      end
      
      if ab_test_goals.reject(&:marked_for_destruction?).length == 0
        errors.add(:base, "Must have atleast one goal")
      end
    end
   
    def started?
      test_group_memberships.count > 0
    end
    
  end
end
