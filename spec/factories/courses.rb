FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Môn học #{n}" }
    sequence(:code) { |n| "CS#{100 + n}" }
    description { "Mô tả môn học" }
    credits     { 3 }
  end
end
