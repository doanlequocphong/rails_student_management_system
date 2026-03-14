module Api
  module V1
    class ClassroomsController < BaseController

      # GET /api/v1/classrooms
      def index
        classrooms = Classroom.recent
        render json: classrooms.map { |c| classroom_json(c) }
      end

      # GET /api/v1/classrooms/:id
      def show
        classroom = Classroom.find(params[:id])
        render json: classroom_json(classroom, detailed: true)
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      private

      def classroom_json(classroom, detailed: false)
        data = {
          id:            classroom.id,
          name:          classroom.name,
          academic_year: classroom.academic_year,
          description:   classroom.description
        }

        if detailed
          data.merge!(
            students_count: classroom.students.count,
            students: classroom.students.by_name.map do |s|
              { id: s.id, name: s.name, email: s.email }
            end
          )
        end

        data
      end
    end
  end
end
