json.id          @course.id
json.code        @course.code
json.name        @course.name
json.credits     @course.credits
json.description @course.description
json.students_count @course.students.count

json.students @course.students.by_name do |student|
  json.id    student.id
  json.name  student.name
  json.email student.email
end
