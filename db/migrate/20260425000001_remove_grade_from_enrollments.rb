class RemoveGradeFromEnrollments < ActiveRecord::Migration[7.1]
  def up
    # Data migration: convert enrollments.grade (0-10) → grades.score (0-100)
    # Preserves existing grade data before dropping the column
    Enrollment.where.not(grade: nil).find_each do |enrollment|
      Grade.find_or_create_by!(
        student_id: enrollment.student_id,
        course_id:  enrollment.course_id,
        grade_type: "final"
      ) do |g|
        g.score = (enrollment.grade * 10).round
      end
    end

    remove_column :enrollments, :grade, :decimal
  end

  def down
    add_column :enrollments, :grade, :decimal, precision: 4, scale: 2
  end
end
