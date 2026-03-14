require "rails_helper"

RSpec.describe "Api::V1::Courses", type: :request do
  let(:user)    { create(:user, :admin) }
  let(:headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  describe "GET /api/v1/courses" do
    before { create_list(:course, 4) }

    it "trả về 200 và danh sách courses" do
      get "/api/v1/courses", headers: headers
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(4)
    end

    it "mỗi course có đúng các fields" do
      get "/api/v1/courses", headers: headers
      course = JSON.parse(response.body).first
      expect(course.keys).to include("id", "code", "name", "credits", "description")
    end

    it "401 khi không có token" do
      get "/api/v1/courses"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/courses/:id" do
    let(:course)  { create(:course) }
    let(:student) { create(:student) }

    before do
      create(:enrollment, student: student, course: course)
    end

    it "trả về 200 và chi tiết course" do
      get "/api/v1/courses/#{course.id}", headers: headers
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["id"]).to eq(course.id)
    end

    it "có thêm students_count và students khi detail" do
      get "/api/v1/courses/#{course.id}", headers: headers
      data = JSON.parse(response.body)
      expect(data.keys).to include("students_count", "students")
      expect(data["students_count"]).to eq(1)
    end

    it "404 khi course không tồn tại" do
      get "/api/v1/courses/99999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/courses/:course_id/grades" do
    let(:course)  { create(:course) }
    let(:student) { create(:student) }

    before do
      create(:enrollment, student: student, course: course)
      create(:grade, student: student, course: course,
             score: 85, grade_type: "midterm")
    end

    it "trả về 200 và grades của course" do
      get "/api/v1/courses/#{course.id}/grades", headers: headers
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.keys).to include("course", "grades")
    end

    it "grades có đầy đủ fields" do
      get "/api/v1/courses/#{course.id}/grades", headers: headers
      grade = JSON.parse(response.body)["grades"].first
      expect(grade.keys).to include("id", "student", "score", "grade_type", "letter", "passed")
    end

    it "letter grade đúng cho score 85 → B" do
      get "/api/v1/courses/#{course.id}/grades", headers: headers
      grade = JSON.parse(response.body)["grades"].first
      expect(grade["letter"]).to eq("B")
    end
  end
end
