class GradesController < ApplicationController
  before_action :set_course
  before_action :set_grade, only: [:update, :destroy]

  def index
    authorize Grade
    @students          = @course.students.by_name
    @grades_by_student = @course.grades
                                .includes(:student)
                                .group_by(&:student_id)
    @grade = Grade.new
  end

  def create
    @grade = Grade.new(grade_params)
    @grade.course = @course
    authorize @grade

    if @grade.save
      redirect_to course_grades_path(@course),
                  notice: "Đã lưu điểm #{@grade.score} cho #{@grade.student.name}."
    else
      @students          = @course.students.by_name
      @grades_by_student = @course.grades.includes(:student).group_by(&:student_id)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    authorize @grade
    if @grade.update(grade_params.except(:student_id))
      redirect_to course_grades_path(@course),
                  notice: "Đã cập nhật điểm thành #{@grade.score}."
    else
      redirect_to course_grades_path(@course),
                  alert: @grade.errors.full_messages.first
    end
  end

  def destroy
    authorize @grade
    student_name = @grade.student.name
    @grade.destroy
    redirect_to course_grades_path(@course),
                notice: "Đã xóa điểm của #{student_name}.",
                status: :see_other
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_grade
    @grade = @course.grades.find(params[:id])
  end

  def grade_params
    params.require(:grade).permit(:student_id, :score, :grade_type, :comment)
  end
end
