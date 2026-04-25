class StudentTranscriptPresenter
  def initialize(student, calculator, grades_by_course)
    @student          = student
    @calculator       = calculator
    @grades_by_course = grades_by_course
  end

  def course_rows
    @grades_by_course.map do |_course_id, grades|
      avg = grades.sum(&:score).to_f / grades.size
      {
        course:       grades.first.course,
        grades:       grades,
        average:      avg.round(1),
        letter_grade: letter_grade_for(avg),
        status:       avg >= Grade::PASSING_SCORE ? :passed : :failed,
        status_label: avg >= Grade::PASSING_SCORE ? 'Đạt' : 'Không đạt',
        row_class:    avg >= Grade::PASSING_SCORE ? 'table-success' : 'table-danger'
      }
    end
  end

  def standing_badge_class
    case @calculator.academic_standing
    when 'Xuất sắc'   then 'badge-success'
    when 'Giỏi'       then 'badge-primary'
    when 'Khá'        then 'badge-info'
    when 'Trung bình' then 'badge-warning'
    else 'badge-danger'
    end
  end

  def gpa            = @calculator.gpa
  def gpa_4          = @calculator.gpa_4
  def standing       = @calculator.academic_standing
  def total_credits  = @calculator.total_credits
  def earned_credits = @calculator.earned_credits
  def student        = @student

  private

  def letter_grade_for(score)
    case score.to_i
    when 90..100 then 'A'
    when 80..89  then 'B'
    when 70..79  then 'C'
    when 60..69  then 'D'
    when 50..59  then 'E'
    else 'F'
    end
  end
end
