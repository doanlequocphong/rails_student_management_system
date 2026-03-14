class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
      # references tự tạo cột FK + index + foreign key constraint
      t.references :student, null: false, foreign_key: true
      t.references :course,  null: false, foreign_key: true

      # Điểm số hệ 100 (nguyên): 0 - 100
      t.integer :score, null: false

      # Loại điểm: "midterm", "final", "assignment", "quiz"
      # null: true — mặc định có thể không phân loại
      t.string :grade_type

      # Ghi chú của giáo viên
      t.text :comment

      t.timestamps
    end

    # Composite index: tìm điểm của 1 sinh viên trong 1 môn nhanh
    add_index :grades, [:student_id, :course_id]
  end
end
