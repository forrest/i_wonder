class Account < ActiveRecord::Base
  scope :active, where(:active => true)
end
