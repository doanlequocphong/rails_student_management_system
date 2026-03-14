module Api
  module V1
    class CoursesController < BaseController

      # GET /api/v1/courses
      def index
        courses = Course.by_name
        render json: courses.map { |c| course_json(c) }
      end

      # GET /api/v1/courses/:id
      def show
        course = Course.find(params[:id])
        render json: course_json(course, detailed: true)
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      private

      def course_json(course, detailed: false)
        data = {
          id:          course.id,
          code:        course.code,
          name:        course.name,
          credits:     course.credits,
          description: course.description
        }

        if detailed
          data.merge!(
            students_count: course.students.count,
            students: course.students.by_name.map do |s|
              { id: s.id, name: s.name, email: s.email }
            end
          )
        end

        data
      end
    end
  end
end
