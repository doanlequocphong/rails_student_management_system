FactoryBot.define do
  factory :grade do
    association :student
    association :course
    score      { 80 }
    grade_type { "midterm" }
    comment    { nil }

    # Trait: điểm đạt
    trait :passing do
      score { 75 }
    end

    # Trait: điểm trượt
    trait :failing do
      score { 40 }
    end

    # Trait: không có grade_type
    trait :no_type do
      grade_type { nil }
    end
  end
end
