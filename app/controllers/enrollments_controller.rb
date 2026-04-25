class EnrollmentsController < ApplicationController
  before_action :set_student

  def create
    course      = Course.find(params[:course_id])
    @enrollment = @student.enrollments.build(course: course)
    authorize @enrollment

    if @enrollment.save
      redirect_to @student, notice: "Đã đăng ký môn #{course.name} thành công."
    else
      redirect_to @student, alert: @enrollment.errors.full_messages.first
    end
  end

  def destroy
    @enrollment = @student.enrollments.find(params[:id])
    authorize @enrollment
    course_name = @enrollment.course.name
    @enrollment.destroy
    redirect_to @student, notice: "Đã hủy đăng ký môn #{course_name}.", status: :see_other
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end

end
