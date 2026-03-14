require "rails_helper"

RSpec.describe Student, type: :model do

  # ── Validations ───────────────────────────────────────────────────
  describe "Validations" do
    it "valid với đầy đủ thông tin hợp lệ" do
      student = build(:student)
      expect(student).to be_valid
    end

    it "invalid khi không có name" do
      student = build(:student, name: "")
      expect(student).not_to be_valid
      expect(student.errors[:name]).to be_present
    end

    it "invalid khi name quá ngắn (< 2 ký tự)" do
      student = build(:student, name: "A")
      expect(student).not_to be_valid
    end

    it "invalid khi email không đúng định dạng" do
      student = build(:student, email: "not-an-email")
      expect(student).not_to be_valid
      expect(student.errors[:email]).to include("không đúng định dạng email")
    end

    it "invalid khi email trùng lặp" do
      create(:student, email: "test@example.com")
      student = build(:student, email: "test@example.com")
      expect(student).not_to be_valid
    end

    it "invalid khi tuổi < 16" do
      student = build(:student, date_of_birth: 10.years.ago.to_date)
      expect(student).not_to be_valid
      expect(student.errors[:date_of_birth]).to include(a_string_matching("phải đủ 16 tuổi"))
    end

    it "valid khi date_of_birth là nil (không bắt buộc)" do
      student = build(:student, date_of_birth: nil)
      expect(student).to be_valid
    end
  end

  # ── Normalization ────────────────────────────────────────────────
  describe "Normalization" do
    it "tự động downcase email" do
      student = create(:student, email: "UPPER@EXAMPLE.COM")
      expect(student.email).to eq("upper@example.com")
    end

    it "tự động strip khoảng trắng email" do
      student = create(:student, email: "  space@example.com  ")
      expect(student.email).to eq("space@example.com")
    end

    it "tự động squeeze khoảng trắng trong name" do
      student = create(:student, name: "Nguyễn  Văn   A")
      expect(student.name).to eq("Nguyễn Văn A")
    end
  end

  # ── GPA Methods ──────────────────────────────────────────────────
  describe "#gpa" do
    let(:student) { create(:student) }

    context "không có điểm" do
      it "trả về nil" do
        expect(student.gpa).to be_nil
      end
    end

    context "có điểm" do
      let(:course1) { create(:course, credits: 4) }
      let(:course2) { create(:course, credits: 3) }

      before do
        # Tạo enrollments
        create(:enrollment, student: student, course: course1)
        create(:enrollment, student: student, course: course2)

        # Tạo grades
        # Course1 (4TC): midterm=85, final=90 → avg = 87.5
        create(:grade, student: student, course: course1, score: 85, grade_type: "midterm")
        create(:grade, student: student, course: course1, score: 90, grade_type: "final")

        # Course2 (3TC): midterm=70, final=75 → avg = 72.5
        create(:grade, student: student, course: course2, score: 70, grade_type: "midterm")
        create(:grade, student: student, course: course2, score: 75, grade_type: "final")
      end

      it "tính GPA có trọng số đúng" do
        # GPA = (87.5×4 + 72.5×3) / (4+3) = (350 + 217.5) / 7 = 81.07
        expect(student.gpa).to eq(81.07)
      end

      it "GPA khác với simple average" do
        # Simple avg = (85+90+70+75)/4 = 80.0
        expect(student.gpa).not_to eq(student.overall_average)
      end
    end

    context "có môn chưa có điểm" do
      let(:course_with_grade)    { create(:course, credits: 3) }
      let(:course_without_grade) { create(:course, credits: 3) }

      before do
        create(:enrollment, student: student, course: course_with_grade)
        create(:enrollment, student: student, course: course_without_grade)
        create(:grade, student: student, course: course_with_grade, score: 80)
      end

      it "bỏ qua môn chưa có điểm (next if course_scores.empty?)" do
        # GPA chỉ tính course_with_grade, không tính course_without_grade
        expect(student.gpa).to eq(80.0)
      end
    end
  end

  describe "#gpa_4" do
    let(:student) { create(:student) }

    it "trả về nil khi không có điểm" do
      expect(student.gpa_4).to be_nil
    end

    {
      95.0 => 4.0,
      85.0 => 3.5,
      75.0 => 3.0,
      67.0 => 2.5,
      62.0 => 2.0,
      55.0 => 1.0,
      40.0 => 0.0
    }.each do |gpa_100, expected_gpa4|
      it "quy đổi GPA #{gpa_100} → #{expected_gpa4}" do
        allow(student).to receive(:gpa).and_return(gpa_100)
        expect(student.gpa_4).to eq(expected_gpa4)
      end
    end
  end

  describe "#academic_standing" do
    let(:student) { create(:student) }

    {
      4.0 => "Xuất sắc",
      3.5 => "Giỏi",
      3.0 => "Khá",
      2.2 => "Trung bình",
      1.5 => "Yếu",
      0.0 => "Kém"
    }.each do |gpa4, expected_standing|
      it "trả về '#{expected_standing}' khi gpa_4 = #{gpa4}" do
        allow(student).to receive(:gpa_4).and_return(gpa4)
        expect(student.academic_standing).to eq(expected_standing)
      end
    end

    it "trả về 'Chưa xác định' khi chưa có điểm" do
      expect(student.academic_standing).to eq("Chưa xác định")
    end
  end

  describe "#overall_average" do
    let(:student) { create(:student) }

    it "trả về nil khi chưa có điểm" do
      expect(student.overall_average).to be_nil
    end

    it "tính trung bình đơn giản tất cả grades" do
      course = create(:course)
      create(:enrollment, student: student, course: course)
      create(:grade, student: student, course: course, score: 80, grade_type: "midterm")
      create(:grade, student: student, course: course, score: 60, grade_type: "final")
      # (80 + 60) / 2 = 70.0
      expect(student.overall_average).to eq(70.0)
    end
  end
end
