json.student do
  json.id   @student.id
  json.name @student.name
end

json.gpa               @calculator.gpa
json.gpa_4             @calculator.gpa_4
json.academic_standing @calculator.academic_standing
json.total_credits     @calculator.total_credits
json.earned_credits    @calculator.earned_credits

json.courses @transcript_data do |row|
  json.code    row[:course].code
  json.name    row[:course].name
  json.credits row[:course].credits
  json.average row[:average_score].round(1)
  json.passed  row[:average_score] >= Grade::PASSING_SCORE
  json.grades  row[:grades] do |grade|
    json.type  grade.grade_type
    json.score grade.score
  end
end
