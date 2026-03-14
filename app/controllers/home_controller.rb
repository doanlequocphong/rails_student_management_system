class HomeController < ApplicationController
  def index
    # Controller chuẩn bị dữ liệu để truyền xuống View
    # Biến instance (@bien) tự động được View truy cập
    @project_name = "Student Management System"
    @current_time = Time.current
    @features = [
      "Quản lý sinh viên",
      "Quản lý lớp học",
      "Quản lý môn học",
      "Bảng điểm"
    ]
  end
end
