module IWonder
  class Metric < ActiveRecord::Base
    BACK_DATE_ITERATIONS = 30
    
    attr_accessible :name, :frequency, :archived, :collection_method, :back_date_snapshots
    attr_accessor :back_date_snapshots
    attr_writer :back_date_snapshots 

    serialize :options, Hash
    attr_accessible :collection_type, :combination_rule, :takes_snapshots
    hash_accessor :options, :collection_type, :default => "event_counter"
    hash_accessor :options, :combination_rule, :default => "sum" # sum or average
    hash_accessor :options, :takes_snapshots, :type => :boolean, :default => true
        
    attr_accessible :event_counter_event, :model_counter_class, :model_counter_scopes, :model_counter_method
    hash_accessor :options, :event_counter_event
    hash_accessor :options, :model_counter_class
    hash_accessor :options, :model_counter_scopes
    hash_accessor :options, :model_counter_method, :default => "Creation Rate" # "Creation Rate" or "Total Number"
    

    has_many :report_memberships
    has_many :reports, :through => :report_memberships
    has_many :snapshots do
      def most_recent
        order("end_time DESC").first
      end
    end

    # ==============================================================================================================================
    # The following methods are for creating the metrics with the coorect values ===================================================
    # ==============================================================================================================================

    validates_length_of :name, :minimum => 1, :message => "can't be blank."

    QUOTE_REMOVER = /(\".*?\")/m # this should strip out quoted text first. This way variables can still be used in where statements
    DANGEROUS_WORDS = /(save|update|create|destroy|delete)/

    before_validation :set_collection_method
    def set_collection_method
      if event_counter_type?
        set_event_collection_method
      elsif model_counter_type?
        set_model_collection_method
      elsif custom_type?
        # It should have saved directly
      end
    end

    before_validation :adjust_snapshot_settings
    def adjust_snapshot_settings
      self.frequency ||= -1
      if self.takes_snapshots_changed? and not self.takes_snapshots?
        self.frequency = -1
      end            
      self.takes_snapshots = !!(self.frequency.nil? or self.frequency > 0)

      true # this preventing it from thinking the validation failed
    end

    validate :avoid_dangerous_words
    def avoid_dangerous_words
      if collection_method.present? and collection_method.gsub(QUOTE_REMOVER, "") =~ DANGEROUS_WORDS
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
          
          if self.model_counter_method == "Creation Rate" and !self.model_counter_class.constantize.respond_to?("created_at")
            errors.add(:base, "Can't calculate creation rate on models without a :created_at column")
          end
          
        rescue Exception => e
          errors.add(:model_counter_class, "is not a valid class")
        end
      end
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
    
    # TODO: some safegaurds need to be added for editing metrics that are already running.
    def locked?
      snapshots.count > 0
    end

  private
  
    def set_event_collection_method
      self.collection_method = "IWonder::Event.where(:event_type => \"#{event_counter_event}\").where(\"created_at >= ? AND created_at < ?\", start_time, end_time).count"
    end
    
    def set_model_collection_method
      query = model_counter_class.dup
      
      if model_counter_scopes.present?
        query += "." unless model_counter_scopes =~ /^\./
        query += model_counter_scopes.dup
      end

      if model_counter_method == "Creation Rate"        
        self.collection_method = "#{query}.where(\"created_at >= ? AND created_at < ?\", start_time, end_time).count"
      else # total numbers
        self.collection_method = "#{query}.count"
      end
    end

    # ==============================================================================================================================
    # The following methods are for data collection and have nothing to do with the intial form creation ===========================
    # ==============================================================================================================================

  public
  
    scope :archived, where(:archived => true)
    scope :active, where("archived = ? or archived IS NULL", false)
    scope :takes_snapshots, where("frequency > 0")
    scope :needs_to_be_measured, active.takes_snapshots.where("last_measurement IS NULL OR last_measurement+(frequency * interval '1 second') < NOW()")

    class << self
      def take_snapshots
        needs_to_be_measured.find_each(&:take_snapshot)
      end
      # handle_asynchronously :take_snapshots
    end
  
    # returns a hash with all the key values between the two times. If it has been collecting integers, the key will be the name of the metric
    def value_from(start_time, end_time)
      if takes_snapshots?
        data = self.snapshots.where("start_time >= ? and end_time <= ?", start_time, end_time).collect(&:data)
      else
        data = [run_collection_method_from(start_time, end_time)]
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
          final_hash[key] = (final_hash[key] || 0.0) + value.to_f
        }
      }
      
      if combination_rule == "average" # we have to now divide by the number of snapshots we added together
        final_hash.each{|key, value|
          final_hash[key] = final_hash[key] / array_of_hashes.length.to_f
        }
      end
      
      return final_hash
    end

    #TODO: some code to avoid overlap in snapshots needs to be added
    def take_snapshot
      start_time, end_time = timeframe_for_next_snapshot
      while end_time <= Time.zone.now do
        self.snapshots.create(:data => run_collection_method_from(start_time, end_time), :start_time => start_time, :end_time => end_time)
      
        if self.earliest_measurement.nil? or self.earliest_measurement > start_time
          self.update_attribute(:earliest_measurement, start_time)
        end
        
        start_time, end_time = timeframe_for_next_snapshot
      end
    end
    
    after_save :back_date_if_chosen
    def back_date_if_chosen
      if @back_date_snapshots and @back_date_snapshots.to_s =~ /1|true|on/i and takes_snapshots? and self.earliest_measurement.nil?
        start_time = Time.zone.now - BACK_DATE_ITERATIONS * frequency
        end_time = start_time + frequency
        start_time += 1.second
        self.snapshots.create(:data => run_collection_method_from(start_time, end_time), :start_time => start_time, :end_time => end_time)
        self.update_attribute(:earliest_measurement, start_time)
        
        # not that the first snapshot is taken, running the :take_snapshot command will fill in the rest
        take_snapshot
      end
    end
    
  private
  
    def run_collection_method_from(start_time, end_time)
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

    def timeframe_for_next_snapshot
      recent = self.snapshots.most_recent
      if recent.present?
        start_time =  recent.end_time
        end_time = start_time + frequency
        start_time += 1.second # this avoids overlap with the previous snapshot
      else
        start_time = Time.zone.now - frequency
        end_time = Time.zone.now
      end
      
      [start_time, end_time]
    end

  end
end
