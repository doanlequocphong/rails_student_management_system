class EnrollmentPolicy < ApplicationPolicy
  # admin   → toàn quyền
  # teacher → có thể tạo + sửa enrollment (nhập điểm enrollment)
  # student → không trực tiếp thao tác enrollment

  def create?  = admin? || teacher?
  def update?  = admin? || teacher?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
