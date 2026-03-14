module Api
  module V1
    class GradesController < BaseController

      # GET /api/v1/courses/:course_id/grades
      # Trả về tất cả điểm của môn học, nhóm theo sinh viên
      def index
        course = Course.find(params[:course_id])
        grades = course.grades.includes(:student).order("students.name")

        render json: {
          course: { id: course.id, code: course.code, name: course.name },
          grades: grades.map do |g|
            {
              id:         g.id,
              student_id: g.student_id,
              student:    g.student.name,
              score:      g.score,
              grade_type: g.grade_type,
              letter:     g.letter_grade,
              passed:     g.passed?,
              comment:    g.comment
            }
          end
        }
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end
end
