class ClassroomPolicy < ApplicationPolicy
  # admin   → toàn quyền + assign/remove student
  # teacher → xem danh sách + chi tiết
  # student → xem danh sách + chi tiết

  def index?          = admin? || teacher? || student?
  def show?           = admin? || teacher? || student?
  def create?         = admin?
  def update?         = admin?
  def destroy?        = admin?
  def assign_student? = admin?
  def remove_student? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
