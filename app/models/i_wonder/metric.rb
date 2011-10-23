module IWonder
  class Metric < ActiveRecord::Base
    attr_accessible :name, :frequency, :collection_method

    has_many :report_memberships
    has_many :reports, :through => :report_memberships
    has_many :snapshots

    validates_length_of :name, :minimum => 1, :message => "can't be blank."

    DANGEROUS_WORDS = /(save|update|create|destroy|delete)/

    scope :archived, where(:archived => true)
    scope :active, where(:archived => false)
    scope :takes_snapshots, where("frequency > 0")
    scope :needs_to_be_measured, active.takes_snapshots.where("last_measurement IS NULL OR last_measurement+(frequency * interval '1 second') < NOW()")

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
      handle_asynchronously :take_measure
    end
  end
end
