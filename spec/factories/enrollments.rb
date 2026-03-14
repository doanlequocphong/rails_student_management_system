FactoryBot.define do
  factory :enrollment do
    association :student
    association :course
    enrolled_at { Date.today }
    grade       { nil }
  end
end
