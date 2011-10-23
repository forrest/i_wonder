FactoryGirl.define do
  sequence :report_name do |n|
    "Report #{n}"
  end
  
  factory :report, :class => IWonder::Report do
    name { Factory.next(:report_name) }
    report_type "line" 

    # t.datetime :min_start
    # t.datetime :max_end
  end
end