module Api
  module V1
    class StudentsController < BaseController

      # GET /api/v1/students → renders index.json.jbuilder
      def index
        @students = Student.by_name.includes(:classroom)
      end

      # GET /api/v1/students/:id → renders show.json.jbuilder
      def show
        @student = Student.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      # GET /api/v1/students/:id/transcript → renders transcript.json.jbuilder
      def transcript
        @student         = Student.find(params[:id])
        @calculator      = GpaCalculatorService.new(student: @student).call
        @transcript_data = TranscriptQuery.new(@student).course_summary
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end
end
