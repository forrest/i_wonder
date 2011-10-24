FactoryGirl.define do
  sequence :metric_name do |n|
    "Measurement #{n}"
  end
    
  factory :metric, :class => IWonder::Metric do
    name { Factory.next(:metric_name) }
    collection_method ""
    frequency 1.day
    collection_type "custom"
  end

end