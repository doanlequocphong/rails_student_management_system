class Classroom < ApplicationRecord
  # ── Normalization ─────────────────────────────────────────────────
  normalizes :name,          with: -> (n) { n.strip }
  normalizes :academic_year, with: -> (y) { y.strip }

  # ── Validations ───────────────────────────────────────────────────
  validates :name,          presence: true,
                            length: { minimum: 2, maximum: 100 }

  validates :academic_year, presence: true,
                            format: { with: /\A\d{4}-\d{4}\z/,
                                      message: "phải đúng định dạng YYYY-YYYY (ví dụ: 2024-2025)" },
                            if: :academic_year?

  validate :academic_year_range_valid, if: :academic_year?

  # ── Scopes ────────────────────────────────────────────────────────
  scope :recent,      -> { order(created_at: :desc) }
  scope :by_name,     -> { order(:name) }
  scope :by_year,     ->(year) { where(academic_year: year) }

  private

  def academic_year_range_valid
    return unless academic_year.match?(/\A\d{4}-\d{4}\z/)

    start_year, end_year = academic_year.split("-").map(&:to_i)
    unless end_year == start_year + 1
      errors.add(:academic_year, "năm kết thúc phải lớn hơn năm bắt đầu đúng 1 năm")
    end
  end
end
