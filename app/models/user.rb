class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ── Callbacks ─────────────────────────────────────────────────────
  # Tự động tạo api_token khi tạo user mới
  before_create :generate_api_token

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

  # Tạo token mới — dùng khi cần reset token
  def regenerate_api_token!
    update!(api_token: generate_token)
  end

  private

  def generate_api_token
    self.api_token = generate_token
  end

  # SecureRandom.hex(24) → chuỗi 48 ký tự ngẫu nhiên, an toàn mật mã
  def generate_token
    loop do
      token = SecureRandom.hex(24)
      break token unless User.exists?(api_token: token)
    end
  end
end
