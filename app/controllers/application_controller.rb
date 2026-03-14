class ApplicationController < ActionController::Base
  # Xử lý khi tìm không thấy record (Student.find(id) không tồn tại)
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to root_path, alert: "Không tìm thấy bản ghi."
  end
end
