require "rails_helper"

RSpec.describe Grade, type: :model do
  # ── Setup data dùng chung ──────────────────────────────────────────
  let(:student)    { create(:student) }
  let(:course)     { create(:course) }
  let(:enrollment) { create(:enrollment, student: student, course: course) }

  # grade hợp lệ — đã có enrollment
  let(:valid_grade) do
    enrollment  # đảm bảo enrollment tồn tại
    build(:grade, student: student, course: course, score: 80, grade_type: "midterm")
  end

  # ── TẦNG 1: Format Validation ─────────────────────────────────────
  describe "Tầng 1 — Format validation" do
    context "score hợp lệ" do
      it "valid khi score trong khoảng 0-100" do
        expect(valid_grade).to be_valid
      end

      it "valid khi score = 0 (biên dưới)" do
        valid_grade.score = 0
        expect(valid_grade).to be_valid
      end

      it "valid khi score = 100 (biên trên)" do
        valid_grade.score = 100
        expect(valid_grade).to be_valid
      end
    end

    context "score không hợp lệ" do
      it "invalid khi score là nil" do
        valid_grade.score = nil
        expect(valid_grade).not_to be_valid
        expect(valid_grade.errors[:score]).to include("can't be blank")
      end

      it "invalid khi score < 0" do
        valid_grade.score = -1
        expect(valid_grade).not_to be_valid
        expect(valid_grade.errors[:score]).to include("phải là số nguyên từ 0 đến 100")
      end

      it "invalid khi score > 100" do
        valid_grade.score = 101
        expect(valid_grade).not_to be_valid
        expect(valid_grade.errors[:score]).to include("phải là số nguyên từ 0 đến 100")
      end

      it "invalid khi score là float (85.5)" do
        valid_grade.score = 85.5
        expect(valid_grade).not_to be_valid
        expect(valid_grade.errors[:score]).to be_present
      end
    end

    context "grade_type" do
      it "valid khi grade_type là một trong GRADE_TYPES" do
        Grade::GRADE_TYPES.each do |type|
          valid_grade.grade_type = type
          expect(valid_grade).to be_valid, "Expected #{type} to be valid"
        end
      end

      it "valid khi grade_type = nil (allow_nil)" do
        valid_grade.grade_type = nil
        expect(valid_grade).to be_valid
      end

      it "invalid khi grade_type không hợp lệ" do
        valid_grade.grade_type = "bonus"
        expect(valid_grade).not_to be_valid
        expect(valid_grade.errors[:grade_type]).to include(
          "phải là: midterm, final, assignment, quiz"
        )
      end
    end
  end

  # ── TẦNG 2: Uniqueness Validation ─────────────────────────────────
  describe "Tầng 2 — Uniqueness validation" do
    context "trùng grade_type trong cùng student + course" do
      before do
        enrollment
        create(:grade, student: student, course: course,
               score: 80, grade_type: "midterm")
      end

      it "invalid khi thêm điểm midterm lần 2 cho cùng sinh viên + môn" do
        duplicate = build(:grade, student: student, course: course,
                          score: 75, grade_type: "midterm")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:grade_type]).to include(
          "sinh viên này đã có điểm loại này cho môn học đó"
        )
      end

      it "valid khi thêm grade_type khác (final) cho cùng sinh viên + môn" do
        different_type = build(:grade, student: student, course: course,
                               score: 90, grade_type: "final")
        expect(different_type).to be_valid
      end
    end

    context "sinh viên khác nhau" do
      let(:other_student)    { create(:student) }
      let(:other_enrollment) { create(:enrollment, student: other_student, course: course) }

      it "valid khi 2 sinh viên khác nhau có cùng grade_type trong cùng môn" do
        enrollment       # sv1 đã đăng ký
        other_enrollment # sv2 đã đăng ký
        create(:grade, student: student,       course: course, grade_type: "midterm")
        grade2 = build(:grade,  student: other_student, course: course, grade_type: "midterm")
        expect(grade2).to be_valid
      end
    end
  end

  # ── TẦNG 3: Business Rule ──────────────────────────────────────────
  describe "Tầng 3 — Business rule: student_must_be_enrolled" do
    context "sinh viên CHƯA đăng ký môn học" do
      it "invalid khi nhập điểm cho sinh viên chưa đăng ký" do
        # Không tạo enrollment!
        grade = build(:grade, student: student, course: course, score: 80)
        expect(grade).not_to be_valid
        expect(grade.errors[:student]).to include(
          a_string_matching("chưa đăng ký môn")
        )
      end
    end

    context "sinh viên ĐÃ đăng ký môn học" do
      it "valid khi nhập điểm cho sinh viên đã đăng ký" do
        enrollment  # tạo enrollment trước
        grade = build(:grade, student: student, course: course, score: 80)
        expect(grade).to be_valid
      end
    end
  end

  # ── Instance Methods ──────────────────────────────────────────────
  describe "#passed?" do
    it "trả về true khi score >= 50" do
      grade = build(:grade, :passing)
      expect(grade.passed?).to be true
    end

    it "trả về false khi score < 50" do
      grade = build(:grade, :failing)
      expect(grade.passed?).to be false
    end

    it "trả về true đúng ở biên: score = 50" do
      grade = build(:grade, score: 50)
      expect(grade.passed?).to be true
    end

    it "trả về false đúng ở biên: score = 49" do
      grade = build(:grade, score: 49)
      expect(grade.passed?).to be false
    end
  end

  describe "#letter_grade" do
    {
      95 => "A",
      85 => "B",
      75 => "C",
      65 => "D",
      55 => "E",
      40 => "F"
    }.each do |score, expected_letter|
      it "trả về #{expected_letter} khi score = #{score}" do
        grade = build(:grade, score: score)
        expect(grade.letter_grade).to eq(expected_letter)
      end
    end
  end

  describe "#grade_type_label" do
    it "trả về nhãn tiếng Việt cho midterm" do
      grade = build(:grade, grade_type: "midterm")
      expect(grade.grade_type_label).to eq("Giữa kỳ")
    end

    it "trả về grade_type gốc nếu không có trong map" do
      grade = build(:grade, grade_type: nil)
      expect(grade.grade_type_label).to be_nil
    end
  end

  # ── Scopes ────────────────────────────────────────────────────────
  describe "Scopes" do
    before do
      enrollment
      create(:grade, :passing, student: student, course: course, grade_type: "midterm")
      create(:grade, :failing, student: student, course: course, grade_type: "final")
    end

    it ".passed trả về grades có score >= 50" do
      expect(Grade.passed.count).to eq(1)
    end

    it ".failed trả về grades có score < 50" do
      expect(Grade.failed.count).to eq(1)
    end

    it ".midterm trả về grades loại midterm" do
      expect(Grade.midterm.count).to eq(1)
    end
  end
end
