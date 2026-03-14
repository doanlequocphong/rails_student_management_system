class CreateEnrollments < ActiveRecord::Migration[7.1]
  def change
    create_table :enrollments do |t|
      # references tự tạo: cột FK + index
      # null: false — sinh viên và môn học bắt buộc phải có
      t.references :student, null: false, foreign_key: true
      t.references :course,  null: false, foreign_key: true

      # Ngày đăng ký — mặc định là thời điểm tạo record
      t.date :enrolled_at

      # Điểm số (0.0 - 10.0), null = chưa có điểm
      t.decimal :grade, precision: 4, scale: 2

      t.timestamps
    end

    # Unique constraint: 1 sinh viên không được đăng ký cùng 1 môn 2 lần
    # Composite index trên cặp (student_id, course_id)
    add_index :enrollments, [:student_id, :course_id], unique: true
  end
end
