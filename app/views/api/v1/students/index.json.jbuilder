json.students @students do |student|
  json.id        student.id
  json.name      student.name
  json.email     student.email
  json.phone     student.phone
  json.classroom student.classroom&.name
end
