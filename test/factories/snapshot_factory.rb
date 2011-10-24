FactoryGirl.define do
  sequence :random_int do |n|
    rand(n + 10)
  end
  
  factory :snapshot, :class => IWonder::Snapshot do
    association :metric
    count { Factory.next(:random_int) }
  end

end