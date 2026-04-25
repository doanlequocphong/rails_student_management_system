class DashboardQuery
  def stats
    {
      students:   Student.count,
      classrooms: Classroom.count,
      courses:    Course.count,
      grades:     Grade.count
    }
  end
end
