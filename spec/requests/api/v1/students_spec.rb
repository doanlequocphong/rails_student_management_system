require "rails_helper"

RSpec.describe "Api::V1::Students", type: :request do
  # Helper: gửi request với token authentication
  let(:user)    { create(:user, :admin) }
  let(:headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  # ── GET /api/v1/students ───────────────────────────────────────────
  describe "GET /api/v1/students" do
    before { create_list(:student, 3) }

    context "với token hợp lệ" do
      it "trả về HTTP 200" do
        get "/api/v1/students", headers: headers
        expect(response).to have_http_status(:ok)
      end

      it "trả về JSON Content-Type" do
        get "/api/v1/students", headers: headers
        expect(response.content_type).to include("application/json")
      end

      it "trả về danh sách sinh viên" do
        get "/api/v1/students", headers: headers
        data = JSON.parse(response.body)
        expect(data.length).to eq(3)
      end

      it "mỗi student có đúng các fields" do
        get "/api/v1/students", headers: headers
        student = JSON.parse(response.body).first
        expect(student.keys).to include("id", "name", "email", "phone", "classroom")
      end

      it "KHÔNG expose api_token hay encrypted_password" do
        get "/api/v1/students", headers: headers
        body = response.body
        expect(body).not_to include("api_token")
        expect(body).not_to include("encrypted_password")
      end
    end

    context "không có token" do
      it "trả về HTTP 401 Unauthorized" do
        get "/api/v1/students"
        expect(response).to have_http_status(:unauthorized)
      end

      it "trả về JSON error message" do
        get "/api/v1/students"
        data = JSON.parse(response.body)
        expect(data["error"]).to be_present
      end
    end

    context "token sai" do
      it "trả về 401" do
        get "/api/v1/students", headers: { "Authorization" => "Bearer wrong_token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ── GET /api/v1/students/:id ───────────────────────────────────────
  describe "GET /api/v1/students/:id" do
    let(:student) { create(:student) }

    context "student tồn tại" do
      it "trả về HTTP 200" do
        get "/api/v1/students/#{student.id}", headers: headers
        expect(response).to have_http_status(:ok)
      end

      it "trả về đúng student" do
        get "/api/v1/students/#{student.id}", headers: headers
        data = JSON.parse(response.body)
        expect(data["id"]).to eq(student.id)
        expect(data["email"]).to eq(student.email)
      end

      it "show detail: có thêm field address, overall_average" do
        get "/api/v1/students/#{student.id}", headers: headers
        data = JSON.parse(response.body)
        expect(data.keys).to include("address", "overall_average", "total_credits")
      end
    end

    context "student không tồn tại" do
      it "trả về HTTP 404" do
        get "/api/v1/students/99999", headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it "trả về JSON error" do
        get "/api/v1/students/99999", headers: headers
        data = JSON.parse(response.body)
        expect(data["error"]).to be_present
      end
    end
  end

  # ── GET /api/v1/students/:id/transcript ───────────────────────────
  describe "GET /api/v1/students/:id/transcript" do
    let(:student)    { create(:student) }
    let(:course)     { create(:course, credits: 3) }

    before do
      create(:enrollment, student: student, course: course)
      create(:grade, student: student, course: course, score: 85, grade_type: "midterm")
      create(:grade, student: student, course: course, score: 90, grade_type: "final")
    end

    it "trả về HTTP 200" do
      get "/api/v1/students/#{student.id}/transcript", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "có đầy đủ GPA fields" do
      get "/api/v1/students/#{student.id}/transcript", headers: headers
      data = JSON.parse(response.body)
      expect(data.keys).to include(
        "student", "gpa", "gpa_4", "academic_standing",
        "total_credits", "earned_credits", "courses"
      )
    end

    it "GPA tính đúng (87.5 trung bình 2 điểm)" do
      get "/api/v1/students/#{student.id}/transcript", headers: headers
      data = JSON.parse(response.body)
      expect(data["gpa"]).to eq(87.5)
    end

    it "courses chứa thông tin môn học" do
      get "/api/v1/students/#{student.id}/transcript", headers: headers
      data   = JSON.parse(response.body)
      course_data = data["courses"].first
      expect(course_data.keys).to include("code", "name", "grades", "average", "passed")
    end
  end
end
