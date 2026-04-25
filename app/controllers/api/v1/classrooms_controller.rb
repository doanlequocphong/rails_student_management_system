module Api
  module V1
    class ClassroomsController < BaseController

      # GET /api/v1/classrooms → renders index.json.jbuilder
      def index
        @classrooms = Classroom.recent
      end

      # GET /api/v1/classrooms/:id → renders show.json.jbuilder
      def show
        @classroom = Classroom.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end
end
