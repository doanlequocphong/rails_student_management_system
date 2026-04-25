json.array! @courses do |course|
  json.id          course.id
  json.code        course.code
  json.name        course.name
  json.credits     course.credits
  json.description course.description
end
