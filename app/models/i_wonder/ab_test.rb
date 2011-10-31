module IWonder
  class AbTest < ActiveRecord::Base
    attr_accessible :name, :sym, :description, :ab_test_goals_attributes, :test_applies_to, :test_group_names, :options, :test_group_data
    serialize :options, Hash
    serialize :test_group_data, Hash
    
    has_many :test_group_memberships, :dependent => :destroy, :foreign_key => "ab_test_sym", :primary_key => :sym

    has_many :ab_test_goals, :dependent => :destroy, :foreign_key => "ab_test_sym", :primary_key => :sym
    accepts_nested_attributes_for :ab_test_goals, :allow_destroy => true
    
    hash_accessor :options, :test_group_names, :type => :array, :reject_blanks => true
    
    validates_presence_of :name, :on => :create, :message => "can't be blank"
    validates_uniqueness_of :name, :on => :create, :message => "must be unique"
    validates_presence_of :sym, :on => :create, :message => "can't be blank"
    validates_format_of :sym, :with => /^[\w\d\_]+$/, :on => :create, :message => "can only contain letters, numbers and underscores"
    validates_uniqueness_of :sym, :on => :create, :message => "must be unique"
    validates_inclusion_of :test_applies_to, :in => %w( session user account ), :on => :create, :message => "extension %s is not included in the list"
    
    validate :has_two_groups_and_a_goal
    def has_two_groups_and_a_goal
      unless test_group_names.length >= 2
        errors.add(:base, "Must have atleast two test groups")
      end
      
      if ab_test_goals.reject(&:marked_for_destruction?).length == 0
        errors.add(:base, "Must have atleast one goal")
      end
    end
      
    after_save :save_to_file
    def save_to_file
      AbTesting::Loader.save_ab_test(self)
    end
      
    def started?
      test_group_memberships.count > 0
    end
    
    def which_test_group?(current_controller)
      if(current_group = get_current_group(current_controller))
        return current_group.test_group_name
      else
        test_group = add_to_test_group(randomly_chosen_test_group, current_controller)
        return test_group.test_group_name
      end
    end
    
    def assigned_count(test_group_name)
      self.test_group_memberships.where(:test_group_name => test_group_name).count
    end
    
    def get_results_for(test_group_name, ab_test_goal)
      scoped_test_group_memberships  = self.test_group_memberships.where(:test_group_name => test_group_name).scoped

      if test_applies_to =~ /account/i
        event_membership_key = "account_id"
      elsif test_applies_to =~ /user/i
        event_membership_key = "user_id"
      else
        event_membership_key = "session_id"
      end
      
      scoped_groups_with_events = scoped_test_group_memberships.joins("LEFT JOIN i_wonder_events ON i_wonder_events.#{event_membership_key} = i_wonder_test_group_memberships.member_id")
      
      scoped_groups_with_goal_events = ab_test_goal.add_goal_to_query(scoped_groups_with_events)
      
      scoped_groups_with_goal_events.count
    end

    
    def from_xml(xml)
      [super]
      
      # make sure it's not blank. Then make sure it's a hash. Then Make sure it's symbolized.
      self.options ||= {}
      self.test_group_data ||= {}
      self.options = {} if self.options.is_a?(String)
      self.test_group_data = {} if self.test_group_data.is_a?(String)
      self.options.symbolize_keys!
      self.test_group_data.symbolize_keys!
      
      hash = Hash.from_xml(xml)
      hash["ab_test"]["ab_test_goals"].each{|ab_test_goal_hash|
        ab_test_goal_hash["options"].symbolize_keys!
        self.ab_test_goals.build(ab_test_goal_hash)
      }
    end
    
    def started_at
      test_group_memberships.minimum(:created_at)
    end
    
  private
    
    def get_current_group(current_controller)
      if test_applies_to =~ /account/i
        env = current_controller.request.env
        test_group_memberships.where(:member_type => "account", :member_id => env[ENV_KEY]["account_id"].to_s).first
      elsif test_applies_to =~ /user/i
        env = current_controller.request.env
        test_group_memberships.where(:member_type => "user", :member_id => env[ENV_KEY]["user_id"].to_s).first
      else
        session_id = current_controller.send("cookies")[COOKIE_KEY+Logging::SESSION_KEY_NAME]
        test_group_memberships.where(:member_type => "session", :member_id => session_id.to_s).first
      end
    end
    
    def add_to_test_group(test_group_name, current_controller)
      if test_applies_to =~ /account/i
        env = current_controller.request.env
        test_group_memberships.create!(:member_type => "account", :member_id => env[ENV_KEY]["account_id"].to_s, :test_group_name => test_group_name)
      elsif test_applies_to =~ /user/i
        env = current_controller.request.env
        test_group_memberships.create!(:member_type => "user", :member_id => env[ENV_KEY]["user_id"].to_s, :test_group_name => test_group_name)
      else
        session_id = current_controller.send("cookies")[COOKIE_KEY+Logging::SESSION_KEY_NAME]
        test_group_memberships.create!(:member_type => "session", :member_id => session_id.to_s, :test_group_name => test_group_name)
      end
    end
    
    def randomly_chosen_test_group
      test_group_names[rand(test_group_names.length)]
    end
    
  end
end
