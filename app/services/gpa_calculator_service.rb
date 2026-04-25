class GpaCalculatorService < ApplicationService
  ACADEMIC_STANDING = {
    (3.6..4.0) => "Xuất sắc",
    (3.2..3.6) => "Giỏi",
    (2.5..3.2) => "Khá",
    (2.0..2.5) => "Trung bình",
    (0.0..2.0) => "Yếu"
  }.freeze

  GPA_4_SCALE = [
    { min: 90, gpa: 4.0 },
    { min: 85, gpa: 3.7 },
    { min: 80, gpa: 3.5 },
    { min: 75, gpa: 3.2 },
    { min: 70, gpa: 3.0 },
    { min: 65, gpa: 2.7 },
    { min: 60, gpa: 2.5 },
    { min: 55, gpa: 2.3 },
    { min: 50, gpa: 2.0 },
    { min: 0,  gpa: 0.0 }
  ].freeze

  def initialize(student:)
    @student = student
  end

  def call
    self
  end

  def overall_average
    @overall_average ||= @student.grades.average(:score)&.round(2) || 0.0
  end

  def gpa
    @gpa ||= calculate_gpa
  end

  def gpa_4
    @gpa_4 ||= convert_to_4_scale(gpa)
  end

  def academic_standing
    @academic_standing ||= ACADEMIC_STANDING.find { |range, _| range.cover?(gpa_4) }&.last || "Chưa xác định"
  end

  def total_credits
    @total_credits ||= @student.courses.sum(:credits)
  end

  def earned_credits
    @earned_credits ||= calculate_earned_credits
  end

  private

  def calculate_gpa
    result = @student.grades
      .joins("INNER JOIN courses ON courses.id = grades.course_id")
      .select(
        "SUM(grades.score * COALESCE(courses.credits, 1)) AS weighted_sum",
        "SUM(COALESCE(courses.credits, 1)) AS total_weight"
      )
      .first

    return 0.0 if result.total_weight.to_f.zero?

    (result.weighted_sum.to_f / result.total_weight.to_f).round(2)
  end

  def calculate_earned_credits
    @student.courses
      .joins(:grades)
      .where("grades.score >= ?", Grade::PASSING_SCORE)
      .where(grades: { student_id: @student.id })
      .sum(:credits)
  end

  def convert_to_4_scale(gpa_100)
    GPA_4_SCALE.find { |entry| gpa_100 >= entry[:min] }&.fetch(:gpa, 0.0) || 0.0
  end
end
