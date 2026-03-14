class AddClassroomToStudents < ActiveRecord::Migration[7.1]
  def change
    # null: true — sinh viên được phép chưa có lớp (optional)
    # foreign_key: true — DB constraint: classroom_id phải tồn tại trong classrooms.id
    add_reference :students, :classroom, null: true, foreign_key: true
  end
end
