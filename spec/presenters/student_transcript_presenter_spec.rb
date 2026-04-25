require "rails_helper"

RSpec.describe StudentTranscriptPresenter, type: :presenter do
  let(:student)  { create(:student) }
  let(:course)   { create(:course, credits: 3) }
  let(:calculator) do
    instance_double(GpaCalculatorService,
      gpa:               75.0,
      gpa_4:             3.0,
      academic_standing: "Khá",
      total_credits:     15,
      earned_credits:    12
    )
  end

  let(:grade_midterm) { create(:grade, student: student, course: course, score: 80, grade_type: "midterm") }
  let(:grade_final)   { create(:grade, student: student, course: course, score: 70, grade_type: "final") }
  let(:grades_by_course) { { course.id => [grade_midterm, grade_final] } }

  let(:presenter) { described_class.new(student, calculator, grades_by_course) }

  # ── #course_rows ─────────────────────────────────────────────────
  describe "#course_rows" do
    subject(:rows) { presenter.course_rows }

    it "trả về 1 row cho mỗi course trong grades_by_course" do
      expect(rows.size).to eq(1)
    end

    it "tính average đúng: (80 + 70) / 2 = 75.0" do
      expect(rows.first[:average]).to eq(75.0)
    end

    it "letter_grade: 75 → C (70..79)" do
      expect(rows.first[:letter_grade]).to eq("C")
    end

    it "status :passed khi avg >= PASSING_SCORE (50)" do
      expect(rows.first[:status]).to      eq(:passed)
      expect(rows.first[:status_label]).to eq("Đạt")
      expect(rows.first[:row_class]).to    eq("table-success")
    end

    it "trả về empty array khi grades_by_course rỗng" do
      empty_presenter = described_class.new(student, calculator, {})
      expect(empty_presenter.course_rows).to be_empty
    end

    context "khi điểm thấp (< PASSING_SCORE)" do
      let(:failing_grades) do
        { course.id => [create(:grade, student: student, course: course, score: 30, grade_type: "final")] }
      end
      let(:failing_presenter) { described_class.new(student, calculator, failing_grades) }

      it "status :failed" do
        row = failing_presenter.course_rows.first
        expect(row[:status]).to      eq(:failed)
        expect(row[:status_label]).to eq("Không đạt")
        expect(row[:row_class]).to    eq("table-danger")
      end

      it "letter_grade: 30 → F" do
        expect(failing_presenter.course_rows.first[:letter_grade]).to eq("F")
      end
    end

    it "row chứa course object đúng" do
      expect(rows.first[:course]).to eq(course)
    end

    it "row chứa tất cả grades" do
      expect(rows.first[:grades]).to match_array([grade_midterm, grade_final])
    end
  end

  # ── #standing_badge_class ─────────────────────────────────────────
  describe "#standing_badge_class" do
    {
      "Xuất sắc"   => "badge-success",
      "Giỏi"       => "badge-primary",
      "Khá"        => "badge-info",
      "Trung bình" => "badge-warning",
      "Yếu"        => "badge-danger"
    }.each do |standing, expected_class|
      it "trả về #{expected_class} cho '#{standing}'" do
        allow(calculator).to receive(:academic_standing).and_return(standing)
        expect(presenter.standing_badge_class).to eq(expected_class)
      end
    end
  end

  # ── Delegation to calculator ──────────────────────────────────────
  describe "delegation to calculator" do
    it "#gpa delegates"            { expect(presenter.gpa).to eq(75.0) }
    it "#gpa_4 delegates"          { expect(presenter.gpa_4).to eq(3.0) }
    it "#standing delegates"       { expect(presenter.standing).to eq("Khá") }
    it "#total_credits delegates"  { expect(presenter.total_credits).to eq(15) }
    it "#earned_credits delegates" { expect(presenter.earned_credits).to eq(12) }
  end

  # ── #student ─────────────────────────────────────────────────────
  describe "#student" do
    it "trả về student object" do
      expect(presenter.student).to eq(student)
    end
  end
end
