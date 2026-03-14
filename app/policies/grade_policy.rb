class GradePolicy < ApplicationPolicy
  # admin   → toàn quyền
  # teacher → quản lý điểm (index, create, update, destroy)
  # student → không được truy cập trực tiếp (xem qua transcript)

  def index?   = admin? || teacher?
  def create?  = admin? || teacher?
  def update?  = admin? || teacher?
  def destroy? = admin? || teacher?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_admin? || user.role_teacher?
        scope.all
      else
        scope.where(student_id: nil)  # student không thấy gì qua route này
      end
    end
  end
end
