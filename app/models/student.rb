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

  # ── Transcript Methods ───────────────────────────────────────────
  # Điểm trung bình tổng tất cả grades (hệ 100) — simple average
  def overall_average
    all_scores = grades.map(&:score)
    return nil if all_scores.empty?

    (all_scores.sum.to_f / all_scores.size).round(1)
  end

  # Tổng tín chỉ đã đăng ký
  def total_credits
    courses.sum(:credits)
  end

  # Tổng tín chỉ đã đạt (TB môn >= 50)
  def earned_credits
    courses.joins(:grades)
           .where(grades: { student_id: id })
           .group("courses.id, courses.credits")
           .having("AVG(grades.score) >= ?", Grade::PASSING_SCORE)
           .sum(:credits)
  end

  # ── GPA Methods ──────────────────────────────────────────────────

  # GPA hệ 100 — trung bình có trọng số (credits là weight)
  # GPA = Σ(avg_score_môn × credits_môn) / Σ(credits)
  def gpa
    enrolled_courses = courses.includes(:grades).to_a
    return nil if enrolled_courses.empty?

    weighted_sum = 0.0
    total_weight = 0

    enrolled_courses.each do |course|
      # Điểm của student này trong môn này
      course_scores = course.grades
                            .select { |g| g.student_id == id }
                            .map(&:score)
      next if course_scores.empty?

      course_avg = course_scores.sum.to_f / course_scores.size
      weight     = course.credits || 1   # mặc định 1 nếu chưa có tín chỉ

      weighted_sum += course_avg * weight
      total_weight += weight
    end

    return nil if total_weight.zero?

    (weighted_sum / total_weight).round(2)
  end

  # Quy đổi GPA hệ 100 sang hệ 4.0
  def gpa_4
    score = gpa
    return nil if score.nil?

    case score
    when 90..100 then 4.0
    when 80...90 then 3.5
    when 70...80 then 3.0
    when 65...70 then 2.5
    when 60...65 then 2.0
    when 50...60 then 1.0
    else              0.0
    end
  end

  # Học lực dựa trên GPA hệ 4
  def academic_standing
    g4 = gpa_4
    return "Chưa xác định" if g4.nil?

    case g4
    when 3.6..4.0 then "Xuất sắc"
    when 3.2...3.6 then "Giỏi"
    when 2.5...3.2 then "Khá"
    when 2.0...2.5 then "Trung bình"
    when 1.0...2.0 then "Yếu"
    else                "Kém"
    end
  end

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
