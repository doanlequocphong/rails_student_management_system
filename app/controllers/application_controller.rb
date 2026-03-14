class ApplicationController < ActionController::Base
  # Yêu cầu đăng nhập trước khi truy cập bất kỳ action nào
  before_action :authenticate_user!

  # Xử lý khi tìm không thấy record (Student.find(id) không tồn tại)
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to root_path, alert: "Không tìm thấy bản ghi."
  end
end
