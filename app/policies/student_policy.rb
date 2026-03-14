class StudentPolicy < ApplicationPolicy
  # admin   → toàn quyền
  # teacher → xem danh sách, xem chi tiết, xem bảng điểm
  # student → chỉ xem trang của chính mình

  def index?      = admin? || teacher?
  def show?       = admin? || teacher? || own_record?
  def create?     = admin?
  def update?     = admin?
  def destroy?    = admin?
  def transcript? = admin? || teacher? || own_record?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_admin? || user.role_teacher?
        scope.all          # admin + teacher thấy tất cả sinh viên
      else
        scope.none         # student không thấy danh sách (chỉ xem mình)
      end
    end
  end

  private

  # Kiểm tra xem student record này có phải của chính user đang login không
  # Dùng khi student role xem trang của mình
  def own_record?
    # Giả sử User có thể liên kết với Student qua email
    student? && record.email == user.email
  end
end
