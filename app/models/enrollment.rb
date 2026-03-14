class Enrollment < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────────
  # belongs_to mặc định: null: false (không optional)
  # → Enrollment PHẢI có student và course
  belongs_to :student
  belongs_to :course

  # ── Validations ───────────────────────────────────────────────────
  # Đảm bảo 1 sinh viên không đăng ký cùng 1 môn 2 lần
  # scope: :course_id → uniqueness chỉ kiểm tra trong phạm vi 1 course
  validates :student_id, uniqueness: { scope: :course_id,
                                       message: "đã đăng ký môn học này rồi" }

  validates :grade, numericality: { greater_than_or_equal_to: 0,
                                    less_than_or_equal_to: 10,
                                    message: "phải từ 0 đến 10" },
                    allow_nil: true

  # ── Callbacks ─────────────────────────────────────────────────────
  # Tự động gán ngày đăng ký nếu chưa có
  before_validation :set_enrolled_at, on: :create

  # ── Scopes ────────────────────────────────────────────────────────
  scope :recent,      -> { order(created_at: :desc) }
  scope :with_grade,  -> { where.not(grade: nil) }
  scope :without_grade, -> { where(grade: nil) }
  scope :passed,      -> { where("grade >= ?", 5.0) }
  scope :failed,      -> { where("grade < ? AND grade IS NOT NULL", 5.0) }

  private

  def set_enrolled_at
    self.enrolled_at ||= Date.today
  end
end
