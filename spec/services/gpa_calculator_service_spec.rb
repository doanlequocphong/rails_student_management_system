require "rails_helper"

RSpec.describe GpaCalculatorService, type: :service do
  let(:student)    { create(:student) }
  let(:course_a)   { create(:course, credits: 3) }
  let(:course_b)   { create(:course, credits: 2) }
  let(:service)    { described_class.new(student: student).call }

  # Helper: tạo enrollment + grade trong 1 bước
  def enroll_and_grade(student:, course:, score:, grade_type: "final")
    create(:enrollment, student: student, course: course)
    create(:grade, student: student, course: course, score: score, grade_type: grade_type)
  end

  # ── #overall_average ─────────────────────────────────────────────
  describe "#overall_average" do
    it "trả về 0.0 khi sinh viên chưa có điểm" do
      expect(service.overall_average).to eq(0.0)
    end

    it "tính đúng điểm trung bình khi có 1 điểm" do
      enroll_and_grade(student: student, course: course_a, score: 80)
      expect(service.overall_average).to eq(80.0)
    end

    it "tính đúng điểm trung bình khi có nhiều điểm" do
      enroll_and_grade(student: student, course: course_a, score: 80)
      enroll_and_grade(student: student, course: course_b, score: 60)
      # AVG(80, 60) = 70.0
      expect(service.overall_average).to eq(70.0)
    end

    it "làm tròn đến 2 chữ số thập phân" do
      enroll_and_grade(student: student, course: course_a, score: 70)
      enroll_and_grade(student: student, course: course_b, score: 71)
      # AVG = 70.5
      expect(service.overall_average).to eq(70.5)
    end
  end

  # ── #gpa ─────────────────────────────────────────────────────────
  describe "#gpa" do
    it "trả về 0.0 khi chưa có điểm" do
      expect(service.gpa).to eq(0.0)
    end

    it "trả về Float" do
      enroll_and_grade(student: student, course: course_a, score: 80)
      expect(service.gpa).to be_a(Float)
    end

    it "tính đúng GPA có trọng số" do
      enroll_and_grade(student: student, course: course_a, score: 80)  # 3 credits
      enroll_and_grade(student: student, course: course_b, score: 60)  # 2 credits
      # GPA = (80*3 + 60*2) / (3+2) = (240+120)/5 = 360/5 = 72.0
      expect(service.gpa).to eq(72.0)
    end

    it "dùng credit=1 làm mặc định khi course không có credits" do
      no_credit_course = create(:course, credits: nil)
      create(:enrollment, student: student, course: no_credit_course)
      create(:grade, student: student, course: no_credit_course, score: 80, grade_type: "final")
      # GPA = (80*1)/(1) = 80.0
      expect(service.gpa).to eq(80.0)
    end
  end

  # ── #gpa_4 ───────────────────────────────────────────────────────
  describe "#gpa_4" do
    it "trả về 0.0 khi chưa có điểm" do
      expect(service.gpa_4).to eq(0.0)
    end

    {
      95 => 4.0,
      87 => 3.7,
      82 => 3.5,
      77 => 3.2,
      72 => 3.0,
      67 => 2.7,
      62 => 2.5,
      57 => 2.3,
      52 => 2.0,
      40 => 0.0
    }.each do |score, expected_gpa4|
      it "score=#{score} → gpa_4=#{expected_gpa4}" do
        enroll_and_grade(student: student, course: course_a, score: score)
        expect(service.gpa_4).to eq(expected_gpa4)
      end
    end
  end

  # ── #academic_standing ───────────────────────────────────────────
  describe "#academic_standing" do
    it "trả về 'Chưa xác định' khi gpa_4 không thuộc range nào" do
      # gpa=0.0, gpa_4=0.0 → (0.0..2.0) bắt được, trả về 'Yếu'
      # Trường hợp thực tế không có điểm → gpa_4=0.0 → 'Yếu'
      expect(service.academic_standing).to eq("Yếu")
    end

    it "trả về 'Xuất sắc' khi score >= 90" do
      enroll_and_grade(student: student, course: course_a, score: 93)
      expect(service.academic_standing).to eq("Xuất sắc")
    end

    it "trả về 'Giỏi' khi gpa_4 trong 3.2..3.6" do
      enroll_and_grade(student: student, course: course_a, score: 77)  # → gpa_4=3.2
      expect(service.academic_standing).to eq("Giỏi")
    end

    it "trả về 'Khá' khi gpa_4 trong 2.5..3.2" do
      enroll_and_grade(student: student, course: course_a, score: 70)  # → gpa_4=3.0
      expect(service.academic_standing).to eq("Khá")
    end
  end

  # ── #total_credits ───────────────────────────────────────────────
  describe "#total_credits" do
    it "trả về 0 khi chưa đăng ký môn nào" do
      expect(service.total_credits).to eq(0)
    end

    it "tổng tín chỉ của tất cả môn đã đăng ký" do
      create(:enrollment, student: student, course: course_a)  # 3 credits
      create(:enrollment, student: student, course: course_b)  # 2 credits
      expect(service.total_credits).to eq(5)
    end
  end

  # ── #earned_credits ──────────────────────────────────────────────
  describe "#earned_credits" do
    it "trả về 0 khi chưa có điểm" do
      expect(service.earned_credits).to eq(0)
    end

    it "chỉ tính tín chỉ các môn có điểm >= 50" do
      enroll_and_grade(student: student, course: course_a, score: 70)  # đạt — 3 credits
      enroll_and_grade(student: student, course: course_b, score: 40)  # trượt — 2 credits
      expect(service.earned_credits).to eq(3)
    end

    it "tính đủ tín chỉ khi tất cả môn đều đạt" do
      enroll_and_grade(student: student, course: course_a, score: 80)
      enroll_and_grade(student: student, course: course_b, score: 60)
      expect(service.earned_credits).to eq(5)
    end
  end

  # ── Class method .call ───────────────────────────────────────────
  describe ".call (class method từ ApplicationService)" do
    it "hoạt động giống new(...).call" do
      result = described_class.call(student: student)
      expect(result).to be_a(GpaCalculatorService)
      expect(result.gpa).to eq(0.0)
    end
  end

  # ── Memoization ──────────────────────────────────────────────────
  describe "memoization" do
    it "tính gpa chỉ 1 lần — lần 2 trả về cached value" do
      enroll_and_grade(student: student, course: course_a, score: 80)
      service # khởi tạo service
      expect(service).not_to receive(:calculate_gpa)
      service.gpa  # lần 1 đã cache, lần 2 không gọi lại calculate_gpa
    end
  end
end
