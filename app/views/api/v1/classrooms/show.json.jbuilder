json.id            @classroom.id
json.name          @classroom.name
json.academic_year @classroom.academic_year
json.description   @classroom.description
json.students_count @classroom.students.count

json.students @classroom.students.by_name do |student|
  json.id    student.id
  json.name  student.name
  json.email student.email
end
