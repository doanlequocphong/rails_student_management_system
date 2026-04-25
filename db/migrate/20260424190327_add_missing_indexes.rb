class AddMissingIndexes < ActiveRecord::Migration[7.1]
  def change
    # students.email: unique index to prevent duplicate emails and speed up lookups
    add_index :students, :email, unique: true, if_not_exists: true

    # grades: composite unique index per grade_type to prevent duplicates
    add_index :grades, [:student_id, :course_id, :grade_type],
              unique: true, name: "index_grades_unique_per_type", if_not_exists: true

    # classrooms.name: for search queries
    add_index :classrooms, :name, if_not_exists: true

    # students.name: for sort queries
    add_index :students, :name, if_not_exists: true
  end
end
