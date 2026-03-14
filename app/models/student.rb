class Student < ApplicationRecord
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

  validates :date_of_birth, comparison: { less_than: Date.today,
                                           message: "phải là ngày trong quá khứ" },
                             allow_nil: true

  # ── Scopes ───────────────────────────────────────────────────────
  # Truy vấn được đặt tên, tái sử dụng dễ dàng
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, -> { order(:name) }
end
