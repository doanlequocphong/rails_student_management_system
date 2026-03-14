class Student < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────────
  # optional: true — sinh viên có thể chưa được xếp lớp
  belongs_to :classroom, optional: true

  # Quan hệ với Enrollment (bảng trung gian)
  # dependent: :destroy — xóa student thì xóa luôn các enrollment
  has_many :enrollments, dependent: :destroy

  # has_many :through — truy cập Course qua Enrollment
  # student.courses → danh sách môn học (1 JOIN query, không N+1)
  has_many :courses, through: :enrollments

  # Điểm số hệ 100 — Grade model riêng biệt
  has_many :grades, dependent: :destroy

  # ── Normalization (Rails 7.1) ─────────────────────────────────────
  # Tự động chuẩn hóa dữ liệu TRƯỚC khi validate và lưu DB
  normalizes :email, with: -> (e) { e.strip.downcase }
  normalizes :name,  with: -> (n) { n.strip.squeeze(" ") }
  normalizes :phone, with: -> (p) { p.strip }
  normalizes :address, with: -> (a) { a.strip }

  # ── Validations ──────────────────────────────────────────────────
  validates :name,  presence: true,
                    length: { minimum: 2, maximum: 100 }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP,
                              message: "không đúng định dạng email" }

  validates :phone, format: { with: /\A[0-9+\-\s()]{7,15}\z/,
                               message: "chỉ được chứa số và ký tự +, -, dấu cách" },
                    allow_blank: true

  # FIX: dùng lambda -> { Date.today } để evaluate lại mỗi lần validate
  # (tránh cache ngày khi server chạy lâu dài)
  validates :date_of_birth,
            comparison: { less_than: -> { Date.today },
                          message: "phải là ngày trong quá khứ" },
            allow_nil: true

  # ── Custom Validations ────────────────────────────────────────────
  validate :age_must_be_reasonable, if: :date_of_birth?

  # ── Scopes ───────────────────────────────────────────────────────
  scope :recent,  -> { order(created_at: :desc) }
  scope :by_name, -> { order(:name) }
  scope :search,  ->(q) { where("name ILIKE :q OR email ILIKE :q", q: "%#{q}%") }

  private

  def age_must_be_reasonable
    age = ((Date.today - date_of_birth) / 365.25).floor
    if age < 16
      errors.add(:date_of_birth, "sinh viên phải đủ 16 tuổi (hiện tại #{age} tuổi)")
    elsif age > 100
      errors.add(:date_of_birth, "tuổi không hợp lệ (#{age} tuổi)")
    end
  end
end
