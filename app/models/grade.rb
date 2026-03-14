class Grade < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────────
  belongs_to :student
  belongs_to :course

  # ── Constants ─────────────────────────────────────────────────────
  # Các loại điểm hợp lệ
  GRADE_TYPES = %w[midterm final assignment quiz].freeze

  # Ngưỡng đạt (hệ 100)
  PASSING_SCORE = 50

  # ── Normalization ─────────────────────────────────────────────────
  normalizes :grade_type, with: -> (t) { t.strip.downcase }

  # ── Validations ───────────────────────────────────────────────────

  # Tầng 1 — Format: score phải là integer 0-100
  validates :score, presence: true,
                    numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    less_than_or_equal_to: 100,
                                    message: "phải là số nguyên từ 0 đến 100" }

  validates :grade_type,
            inclusion: { in: GRADE_TYPES,
                         message: "phải là: #{GRADE_TYPES.join(', ')}" },
            allow_nil: true

  # Tầng 2 — Uniqueness: 1 SV chỉ có 1 điểm/loại/môn
  # scope: [:student_id, :course_id] → "grade_type unique trong (student + course)"
  validates :grade_type,
            uniqueness: { scope: [:student_id, :course_id],
                          message: "sinh viên này đã có điểm loại này cho môn học đó" },
            allow_nil: true

  # Tầng 3 — Business Rule (custom validate):
  # SV phải đăng ký môn học trước khi được nhập điểm
  validate :student_must_be_enrolled

  # ── Scopes ────────────────────────────────────────────────────────
  scope :recent,       -> { order(created_at: :desc) }
  scope :by_score,     -> { order(score: :desc) }
  scope :passed,       -> { where("score >= ?", PASSING_SCORE) }
  scope :failed,       -> { where("score < ?", PASSING_SCORE) }
  scope :by_type,      ->(type) { where(grade_type: type) }
  scope :midterm,      -> { by_type("midterm") }
  scope :final,        -> { by_type("final") }

  # ── Instance Methods ──────────────────────────────────────────────
  def passed?
    score >= PASSING_SCORE
  end

  def letter_grade
    case score
    when 90..100 then "A"
    when 80..89  then "B"
    when 70..79  then "C"
    when 60..69  then "D"
    when 50..59  then "E"
    else              "F"
    end
  end

  def grade_type_label
    {
      "midterm"    => "Giữa kỳ",
      "final"      => "Cuối kỳ",
      "assignment" => "Bài tập",
      "quiz"       => "Kiểm tra"
    }[grade_type] || grade_type
  end

  private

  # Tầng 3: Kiểm tra SV có đăng ký môn này chưa
  # Nếu chưa → không được nhập điểm
  def student_must_be_enrolled
    return unless student && course

    unless Enrollment.exists?(student: student, course: course)
      errors.add(:student, "chưa đăng ký môn #{course.name} — không thể nhập điểm")
    end
  end
end
