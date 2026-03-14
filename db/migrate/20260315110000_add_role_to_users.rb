class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    # role lưu dạng integer (0=admin, 1=teacher, 2=student)
    # default: 2 → user mới đăng ký tự động là "student"
    add_column :users, :role, :integer, default: 2, null: false
  end
end
