module IWonder
  class AbTestGoal < ActiveRecord::Base
    attr_accessible :goal_type, :event_type, :page_view_controller, :page_view_action, :options
    
    belongs_to :ab_test, :foreign_key => "ab_test_sym", :primary_key => :sym
    
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
    
    def add_goal_to_query(scoped_statement)
      if tracks_event?
        sc = scoped_statement.where("i_wonder_events.event_type = ?", event_type)
      else
        sc = scoped_statement.where("i_wonder_events.event_type = ? AND controller = ?", "hit", page_view_controller)
        
        if page_view_action.present?
          sc = sc.where("i_wonder_events.action = ?", page_view_action)
        end
      end
      
      sc.where("i_wonder_events.created_at > ?", self.ab_test.started_at) # event had to come after goal
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
