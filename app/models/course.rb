class Course < ApplicationRecord
  # ── Normalization ─────────────────────────────────────────────────
  # Strip khoảng trắng thừa trước/sau
  normalizes :name,        with: -> (n) { n.strip }
  # Mã môn: chuẩn hóa về UPPERCASE và bỏ khoảng trắng
  normalizes :code,        with: -> (c) { c.strip.upcase }
  normalizes :description, with: -> (d) { d.strip }

  # ── Validations ───────────────────────────────────────────────────
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 100 }

  validates :code, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[A-Z0-9]{2,10}\z/,
                             message: "chỉ được chứa chữ hoa và số, 2-10 ký tự (VD: CS101, MATH3)" }

  validates :credits, numericality: { only_integer: true,
                                      greater_than: 0,
                                      less_than_or_equal_to: 10,
                                      message: "phải là số nguyên từ 1 đến 10" },
                      allow_nil: true

  # ── Scopes ────────────────────────────────────────────────────────
  scope :recent,   -> { order(created_at: :desc) }
  scope :by_name,  -> { order(:name) }
  scope :by_code,  -> { order(:code) }
  scope :search,   ->(q) { where("name ILIKE :q OR code ILIKE :q", q: "%#{q}%") }
end
