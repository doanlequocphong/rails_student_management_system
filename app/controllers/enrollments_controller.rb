class EnrollmentsController < ApplicationController
  before_action :set_student

  def create
    course = Course.find(params[:course_id])
    authorize @student.enrollments.build(course: course)

    service = EnrollmentService.new(student: @student, course: course).call.enroll!

    if service.success?
      redirect_to @student, notice: "Đã đăng ký môn #{course.name} thành công."
    else
      redirect_to @student, alert: service.error
    end
  end

  def destroy
    @enrollment = @student.enrollments.find(params[:id])
    authorize @enrollment
    course_name = @enrollment.course.name

    service = EnrollmentService.new(enrollment: @enrollment).call.cancel!

    redirect_to @student,
      notice: (service.success? ? "Đã hủy đăng ký môn #{course_name}." : service.error),
      status: :see_other
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end
end
