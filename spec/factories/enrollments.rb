FactoryBot.define do
  factory :enrollment do
    association :student
    association :course
    enrolled_at { Date.today }
  end
end
