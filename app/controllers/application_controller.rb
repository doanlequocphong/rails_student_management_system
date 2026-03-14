class ApplicationController < ActionController::Base
  # Dùng layout khác nhau tùy loại controller:
  #   devise_controller? → layout "devise" (login/register page)
  #   còn lại            → layout "admin"  (dashboard)
  layout :layout_by_resource

  # Yêu cầu đăng nhập trước khi truy cập bất kỳ action nào
  before_action :authenticate_user!

  # Kích hoạt Pundit authorization cho toàn app
  include Pundit::Authorization

  # Xử lý khi user không có quyền (Pundit raise lỗi này)
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Xử lý khi tìm không thấy record (Student.find(id) không tồn tại)
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def user_not_authorized
    redirect_to root_path, alert: "Bạn không có quyền thực hiện thao tác này."
  end

  def record_not_found
    redirect_to root_path, alert: "Không tìm thấy bản ghi."
  end

  # Devise controllers (sessions, registrations, passwords...)  → layout "devise"
  # Tất cả controllers còn lại                                  → layout "admin"
  def layout_by_resource
    devise_controller? ? "devise" : "admin"
  end
end
