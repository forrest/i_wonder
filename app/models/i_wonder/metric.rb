module IWonder
  class Metric < ActiveRecord::Base
    attr_accessible :name, :frequency, :collection_method

    has_many :reports, :through => :report_membership
    has_many :snapshots, :foreign_key => "i_wonder_metric_id"

    validates_length_of :name, :minimum => 1, :message => "can't be blank."

    DANGEROUS_WORDS = /(save|update|create|destroy|delete)/

    scope :needs_to_be_measured, where("i_wonder_metrics.frequency > 0 AND (i_wonder_metrics.last_measurement IS NULL OR i_wonder_metrics.last_measurement+(i_wonder_metrics.frequency * interval '1 second') < NOW())")

    validate :avoid_dangerous_words
    def avoid_dangerous_words
      if collection_method.present? and collection_method =~ DANGEROUS_WORDS
        errors.add(:collection_method, "Doesn't like the word \"#{$1}\"")
      end
    end

    def locked?
      snapshots.count > 0
    end

    class << self
      def take_measurements
        needs_to_be_measured.find_each{|metric|
          # this ensures that even if things go wrong, the damage get's rolled back.
          @resulting_data = nil

          transaction do
            @resulting_data = eval(metric.collection_method)
            raise ActiveRecord::Rollback
          end
          metric.snapshots.create(:data => @resulting_data)
        }
      end
      # handle_asynchronously :take_measure
    end
  end
end
