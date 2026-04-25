class HomeController < ApplicationController
  def index
    @project_name = "Student Management System"
    @current_time = Time.current

    @stats = DashboardQuery.new.stats
  end
end
