module IWonder
  class Snapshot < ActiveRecord::Base
    attr_accessible :data
    serialize :complex_data, Hash
    
    belongs_to :metric
    
    validates_presence_of :metric
    validate :has_some_data
    def has_some_data
      if count.blank? and complex_data.blank?
        errors.add(:base, "must have some data")
      end
    end
    
    def data=(some_form_of_data)
      if some_form_of_data.is_a?(Hash)
        self.complex_data = some_form_of_data
      else
        self.count = some_form_of_data.to_i
      end
    end
    
    def data
      self.count || self.complex_data
    end
    
    def complex?
      self.complex_data.present?
    end
  end
end
