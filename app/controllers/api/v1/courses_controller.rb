module Api
  module V1
    class CoursesController < BaseController

      # GET /api/v1/courses → renders index.json.jbuilder
      def index
        @courses = Course.by_name
      end

      # GET /api/v1/courses/:id → renders show.json.jbuilder
      def show
        @course = Course.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end
end
