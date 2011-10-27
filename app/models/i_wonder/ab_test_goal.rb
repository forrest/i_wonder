module IWonder
  class AbTestGoal < ActiveRecord::Base
    belongs_to :ab_test
    
    attr_accessible :goal_type, :event_type, :page_view_controller, :page_view_action
    serialize :options, Hash
    hash_accessor :options, :goal_type, :default => "Event"
    hash_accessor :options, :event_type
    hash_accessor :options, :page_view_controller
    hash_accessor :options, :page_view_action
    
    validates_inclusion_of :goal_type, :in => ["Event", "Page View"]
    validates_presence_of :event_type, :if => :tracks_event?
    validates_presence_of :page_view_controller, :if => :tracks_page_view?
    
    def tracks_event?
      goal_type == "Event"
    end
    
    def tracks_page_view?
      goal_type == "Page View"
    end
    
    def goal_scope
      if tracks_event?
        Event.where(:event_type => event_type)
      else
        sc = Event.where(:event_type => "hit", :controller => page_view_controller)
        
        if page_view_action.present?
          sc = sc.where(:action => page_view_action)
        end
        
        sc
      end
    end
    
    def to_s
      if tracks_event?
        "#{event_type} occurred"
      elsif page_view_action.present?
        "#{page_view_controller}##{page_view_action} hit"
      else
        "any #{page_view_controller} hit"
      end
    end
    
  end
end
