class ApplicationPolicy
  # user   = người đang đăng nhập (current_user)
  # record = object đang được kiểm tra (ví dụ: @student)
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  # Mặc định: TẤT CẢ actions đều bị từ chối
  # Subclass override từng method để cho phép
  def index?  = false
  def show?   = false
  def create? = false
  def new?    = create?
  def update? = false
  def edit?   = update?
  def destroy? = false

  # Scope — lọc danh sách record user được thấy
  # Mặc định: không thấy gì cả
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class}#resolve is not implemented."
    end

    private

    attr_reader :user, :scope
  end

  private

  # Helper methods dùng trong tất cả policies con
  def admin?   = user.role_admin?
  def teacher? = user.role_teacher?
  def student? = user.role_student?
end
