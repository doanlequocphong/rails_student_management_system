class TranscriptQuery
  def initialize(student)
    @student = student
  end

  def grades_by_course
    @student.grades
      .includes(:course)
      .order('courses.name, grade_type')
      .group_by(&:course_id)
  end

  def course_summary
    grades_by_course.map do |_course_id, grades|
      {
        course:        grades.first.course,
        grades:        grades,
        average_score: grades.sum(&:score).to_f / grades.size
      }
    end
  end
end
