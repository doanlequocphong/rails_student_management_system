class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ── Roles ─────────────────────────────────────────────────────────
  # Lưu role dạng integer trong DB, Rails tự map sang symbol
  # 0 = admin, 1 = teacher, 2 = student (default)
  enum :role, { admin: 0, teacher: 1, student: 2 }, prefix: true

  # ── Helper Methods ─────────────────────────────────────────────────
  # Kiểm tra role — dùng trong Policy và View
  # Rails tự tạo: role_admin?, role_teacher?, role_student?
  # nhờ prefix: true ở trên

  def display_role
    {
      "admin"   => "Quản trị viên",
      "teacher" => "Giáo viên",
      "student" => "Sinh viên"
    }[role] || role
  end
end
