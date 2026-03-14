class EnrollmentsController < ApplicationController
  # @student luôn phải có — enrollment thuộc về student
  before_action :set_student

  # POST /students/:student_id/enrollments
  # Đăng ký sinh viên vào môn học
  def create
    course = Course.find(params[:course_id])
    @enrollment = @student.enrollments.build(course: course)

    if @enrollment.save
      redirect_to @student, notice: "Đã đăng ký môn #{course.name} thành công."
    else
      redirect_to @student, alert: @enrollment.errors.full_messages.first
    end
  end

  # PATCH /students/:student_id/enrollments/:id
  # Cập nhật điểm số
  def update
    @enrollment = @student.enrollments.find(params[:id])

    if @enrollment.update(enrollment_params)
      redirect_to @student, notice: "Đã cập nhật điểm môn #{@enrollment.course.name}."
    else
      redirect_to @student, alert: @enrollment.errors.full_messages.first
    end
  end

  # DELETE /students/:student_id/enrollments/:id
  # Hủy đăng ký môn học
  def destroy
    @enrollment = @student.enrollments.find(params[:id])
    course_name = @enrollment.course.name
    @enrollment.destroy
    redirect_to @student, notice: "Đã hủy đăng ký môn #{course_name}.", status: :see_other
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end

  # Chỉ permit grade — không cho phép đổi student/course qua form
  def enrollment_params
    params.require(:enrollment).permit(:grade)
  end
end
