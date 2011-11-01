FactoryGirl.define do
  factory :ab_test, :class => IWonder::AbTest do
    sequence(:name) {|n| "Test #{n}" }
    sequence(:sym) {|n| "test_#{n}" }
    test_group_names ["Options 1", "Options 2"]
    test_applies_to "session"
    
    ab_test_goals {|ab_test_goals|  [ab_test_goals.association(:test_goal)]  }
  end
  
  factory :test_goal, :class => IWonder::AbTestGoal do
    event_type "success"
  end

end
