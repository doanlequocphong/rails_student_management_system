module Api
  module V1
    class StudentsController < BaseController

      # GET /api/v1/students
      def index
        students = Student.by_name.includes(:classroom)
        render json: students.map { |s| student_json(s) }
      end

      # GET /api/v1/students/:id
      def show
        student = Student.find(params[:id])
        render json: student_json(student, detailed: true)
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      # GET /api/v1/students/:id/transcript
      def transcript
        student = Student.find(params[:id])

        enrollments      = student.enrollments.includes(:course)
        grades_by_course = student.grades.group_by(&:course_id)

        render json: {
          student:          student_json(student),
          gpa:              student.gpa,
          gpa_4:            student.gpa_4,
          academic_standing: student.academic_standing,
          total_credits:    student.total_credits,
          earned_credits:   student.earned_credits,
          courses: enrollments.map do |e|
            course_grades = grades_by_course[e.course_id] || []
            avg = course_grades.any? ? (course_grades.sum(&:score).to_f / course_grades.size).round(1) : nil
            {
              code:    e.course.code,
              name:    e.course.name,
              credits: e.course.credits,
              grades:  course_grades.map { |g| { type: g.grade_type, score: g.score } },
              average: avg,
              passed:  avg ? avg >= Grade::PASSING_SCORE : nil
            }
          end
        }
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      private

      def student_json(student, detailed: false)
        data = {
          id:            student.id,
          name:          student.name,
          email:         student.email,
          phone:         student.phone,
          date_of_birth: student.date_of_birth,
          classroom:     student.classroom&.name
        }

        if detailed
          data.merge!(
            address:          student.address,
            overall_average:  student.overall_average,
            total_credits:    student.total_credits
          )
        end

        data
      end
    end
  end
end
