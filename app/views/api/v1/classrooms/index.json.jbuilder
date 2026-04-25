json.classrooms @classrooms do |classroom|
  json.id            classroom.id
  json.name          classroom.name
  json.academic_year classroom.academic_year
  json.description   classroom.description
end
