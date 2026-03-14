FactoryBot.define do
  factory :classroom do
    # sequence: đảm bảo mỗi factory tạo ra tên khác nhau
    sequence(:name) { |n| "Lớp K#{n}" }
    academic_year { "2024-2025" }
    description   { "Mô tả lớp học" }
  end
end
