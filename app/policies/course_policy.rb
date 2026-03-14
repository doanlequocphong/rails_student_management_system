class CoursePolicy < ApplicationPolicy
  # admin   → toàn quyền
  # teacher → xem danh sách + chi tiết
  # student → xem danh sách + chi tiết

  def index?   = admin? || teacher? || student?
  def show?    = admin? || teacher? || student?
  def create?  = admin?
  def update?  = admin?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all   # tất cả roles đều thấy danh sách môn học
    end
  end
end
