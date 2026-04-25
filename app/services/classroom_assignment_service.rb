class ClassroomAssignmentService < ApplicationService
  attr_reader :error

  def initialize(classroom:, student:)
    @classroom = classroom
    @student   = student
  end

  def call = self

  def assign!
    @student.update!(classroom: @classroom)
    @success = true
    self
  rescue ActiveRecord::RecordInvalid => e
    @error   = e.message
    @success = false
    self
  end

  def remove!
    @student.update!(classroom: nil)
    @success = true
    self
  rescue ActiveRecord::RecordInvalid => e
    @error   = e.message
    @success = false
    self
  end

  def success? = @success == true
  def failure? = !success?
end
