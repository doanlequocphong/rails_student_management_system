class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      # Tên môn học: "Toán cao cấp", "Lập trình Ruby on Rails"
      t.string :name, null: false

      # Mã môn học: "MATH101", "CS301" — ngắn, duy nhất
      t.string :code, null: false

      # Mô tả môn học (tùy chọn)
      t.text :description

      # Số tín chỉ (tùy chọn, mặc định nil)
      t.integer :credits

      t.timestamps
    end

    # Index unique trên code — DB constraint, không chỉ Rails validation
    add_index :courses, :code, unique: true
  end
end
