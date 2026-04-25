class EnrollmentService < ApplicationService
  attr_reader :enrollment, :error

  def initialize(student: nil, course: nil, enrollment: nil)
    @student    = student
    @course     = course
    @enrollment = enrollment
  end

  def call
    self
  end

  def enroll!
    @enrollment = @student.enrollments.build(course: @course, enrolled_at: Date.current)
    if @enrollment.save
      @success = true
    else
      @error   = @enrollment.errors.full_messages.join(", ")
      @success = false
    end
    self
  end

  def cancel!
    @enrollment.destroy
    @success = true
    self
  rescue => e
    @error   = e.message
    @success = false
    self
  end

  def success? = @success == true
  def failure? = !success?
end
