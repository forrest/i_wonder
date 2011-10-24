module IWonder
  class Metric < ActiveRecord::Base
    attr_accessible :name, :frequency, :active

    serialize :options, Hash
    attr_accessible :event_counter_event, :collection_type
    hash_accessor :options, :collection_type, :default => "event_counter"
    hash_accessor :options, :event_counter_event
        
    attr_accessible :model_counter_class, :model_counter_scopes, :model_counter_takes_snapshots, :model_counter_frequency
    hash_accessor :options, :model_counter_class
    hash_accessor :options, :model_counter_scopes
    hash_accessor :options, :model_counter_takes_snapshots, :type => :boolean, :default => true
    hash_accessor :options, :model_counter_frequency, :type => :integer
    hash_accessor :options, :model_counter_back_date, :type => :boolean, :default => true
    
    attr_accessible :custom_collection_method, :custom_takes_snapshots, :custom_frequency, :combination_rule
    hash_accessor :options, :custom_collection_method
    hash_accessor :options, :custom_takes_snapshots, :type => :boolean, :default => true
    hash_accessor :options, :custom_frequency
    hash_accessor :options, :combination_rule, :default => "sum" # sum or average
    

    has_many :report_memberships
    has_many :reports, :through => :report_memberships
    has_many :snapshots do
      def most_recent
        order("created_at DESC").first
      end
    end

    validates_length_of :name, :minimum => 1, :message => "can't be blank."

    QUOTE_REMOVER = /"[^"]*"/ # this should strip out quoted text first. This way variables can still be used in where statements
    DANGEROUS_WORDS = /(save|update|create|destroy|delete)/

    scope :archived, where(:archived => true)
    scope :active, where("archived = ? or archived IS NULL", false)
    scope :takes_snapshots, where("frequency > 0")
    scope :needs_to_be_measured, active.takes_snapshots.where("last_measurement IS NULL OR last_measurement+(frequency * interval '1 second') < NOW()")

    before_validation :set_frequency
    def set_frequency
      if model_counter_type?
        if self.model_counter_takes_snapshots?
          self.frequency = self.model_counter_frequency
        else
          self.frequency = -1
        end
      elsif custom_type?
        if self.custom_takes_snapshots?
          self.frequency = self.custom_frequency
        else
          self.frequency = -1
        end
      else
        self.frequency = -1
      end
      
      # save it back incase of edits
      self.model_counter_takes_snapshots = self.takes_snapshots?
      self.custom_takes_snapshots = self.takes_snapshots?
      self.model_counter_frequency = self.frequency
      self.custom_frequency = self.frequency
    end

    before_validation :set_collection_method
    def set_collection_method
      if custom_type?
        self.collection_method = self.custom_collection_method
      elsif event_counter_type?
        self.collection_method = "IWonder::Event.where(:....)"
      end
    end

    validate :avoid_dangerous_words
    def avoid_dangerous_words
      if collection_method.present? and collection_method.gsub(QUOTE_REMOVER) =~ DANGEROUS_WORDS
        errors.add(:collection_method, "Doesn't like the word \"#{$1}\"")
      end
    end

    validate :model_counter_is_valid
    def model_counter_is_valid
      if model_counter_type?
        
        begin
          self.model_counter_class.constantize
          
          if self.model_counter_scopes.present?
            if self.model_counter_scopes =~ /\s/
              errors.add(:model_counter_scopes, "can't contain spaces")
            elsif self.model_counter_scopes =~ DANGEROUS_WORDS
              errors.add(:model_counter_scopes, "can't contain dangerous words (save|update|create|destroy|delete)")
            else
              self.model_counter_scopes.split(".").each{|sc|
                unless self.model_counter_class.constantize.respond_to?(sc)
                  errors.add(:model_counter_scopes, "doesn't respond to '#{sc}'")
                end
              }
            end
          end
        rescue Exception => e
          errors.add(:model_counter_class, "is not a valid class")
        end
      end
    end

    

    def locked?
      snapshots.count > 0
    end

    def event_counter_type?
      self.collection_type == "event_counter" or self.collection_type.nil?
    end
    def model_counter_type?
      self.collection_type == "model_counter"
    end
    def custom_type?
      self.collection_type == "custom"
    end
    
    def takes_snapshots?
      self.frequency && self.frequency > 0
    end

    # returns a hash with all the key values between the two times. If it has been collecting integers, the key will be the name of the metric
    def value_from(start_time, end_time)
      if takes_snapshots?
        data = self.snapshots.where("created_at >= ? and created_at < ?", start_time, end_time).collect(&:data)
      else
        data = [self.grab_values_from(start_time, end_time)]
      end
      
      # at this point we have an array of hashs or integers
      
      array_of_hashes = data.collect{|d| 
        d.is_a?(Hash) ? d.stringify_keys! : {self.name => d}
      }
      
      # At this point we have an array of hashes where the key is the series name. Now we have to merge them into a single hash
      
      # TODO: if it is a custom metric, follow the combination_rule
      final_hash = {}
      array_of_hashes.each{|hash|
        hash.each{|key, value|
          final_hash[key] = (final_hash[key] || 0) + value.to_i
        }
      }
      
      return final_hash
    end
    
    
    def grab_values_from(start_time, end_time)
      @resulting_data = nil
      transaction do
        @resulting_data = eval(collection_method)
        raise ActiveRecord::Rollback
      end
      
      # this is a common error. Returning the array of items instead of the item.
      unless @resulting_data.is_a?(Fixnum) or @resulting_data.is_a?(Hash)
        raise "Metric function did not return an integer or a hash"
      end
      
      return @resulting_data
    end

    class << self
      def take_measurements
        needs_to_be_measured.find_each{|metric|
          recent = metric.snapshots.most_recent
          start_at = recent.present? ? recent.created_at : Time.zone.now - frequency
          end_at = Time.zone.now
          metric.snapshots.create(:data => grab_values_from(start_time, end_time))
        }
      end
      # handle_asynchronously :take_measurements
    end
  end
end
