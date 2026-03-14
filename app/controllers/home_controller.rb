class HomeController < ApplicationController
  def index
    @project_name = "Student Management System"
    @current_time = Time.current

    # Dashboard stats
    @students_count   = Student.count
    @classrooms_count = Classroom.count
    @courses_count    = Course.count
    @grades_count     = Grade.count
  end
end
