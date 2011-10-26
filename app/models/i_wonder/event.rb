module IWonder
  class Event < ActiveRecord::Base
    attr_accessible :event_type, :account_id, :user_id, :session_id, :controller, :action, :referrer, :user_agent, :remote_ip
    serialize :extra_details, Hash
   
    validates_presence_of :event_type, :on => :create, :message => "can't be blank"
    
    class << self
      def merge_session_to_user(session_id, user_id)
        # grab the session_id off of the new_visitor attached to that user
        new_visitor_event = Event.where(:user_id => user_id, :event_type => "new_visitor").first
        original_session_id = (new_visitor_event ? new_visitor_event.session_id : session_id)
        

        # for all events on the current session, attach the user and session from that first event
        update_all({:user_id => user_id, :session_id => original_session_id}, ["session_id = ? AND user_id IS NULL", session_id])
        
        # Change the new_visitor to a return_visit
        if new_visitor_event and original_session_id != session_id
          update_all({:event_type => "return_visit"}, ["user_id = ? AND event_type = ? AND id <> ?", user_id, "new_visitor", new_visitor_event.id])
        end
        
        return original_session_id
      end
      # handle_asynchronously :merge_session_to_user
      
      
      def fast_create(attr_hash)
        attr_hash[:created_at] = Time.zone.now.utc
        attr_hash[:updated_at] = Time.zone.now.utc
        
        keys = [:event_type, :account_id, :user_id, :session_id, :controller, :action, :extra_details, :remote_ip, :user_agent, :referrer, :created_at, :updated_at]
        key_str = keys.collect(&:to_s).join(", ")
        
        pre_value = keys.collect{ "?" }.join(", ")
        values_array = keys.collect{|k|
          v = attr_hash[k] 
          v = v.delete_blank.to_yaml if v.is_a?(Hash)
          v
        }
        value_str = sanitize_sql_array( [pre_value] +  values_array) 
        
        Event.connection.execute "INSERT INTO #{table_name} (#{key_str}) values (#{value_str})"
      end
      
      # returns an array of hashes. Each one has a {:event_type, :count, :most_recent} and is sorted by decending most_recent
      def groups
        Event.select("event_type, COUNT(event_type) as count, MAX(created_at) as most_recent").group("event_type").order("most_recent DESC").collect{|e|
          {
            :event_type => e["event_type"],
            :count => e["count"].to_i,
            :most_recent => Time.parse(e["most_recent"])
          }
        }
      end

      
      def get_details_for_event_type(type)
        Event.where(:event_type => type).select("COUNT(event_type) as count, MAX(created_at) as most_recent").group("event_type").collect{|e|
          {
            :event_type => type,
            :count => e["count"].to_i,
            :most_recent => Time.parse(e["most_recent"])
          }
        }.first
      end
      
    end
  end
end
