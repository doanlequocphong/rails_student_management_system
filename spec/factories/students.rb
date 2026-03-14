FactoryBot.define do
  factory :student do
    sequence(:name)  { |n| "Sinh viên #{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
    phone         { "0901234567" }
    date_of_birth { 20.years.ago.to_date }
    address       { "Hà Nội" }
    classroom     { nil }

    # Trait: sinh viên đã được xếp lớp
    trait :with_classroom do
      association :classroom
    end
  end
end
