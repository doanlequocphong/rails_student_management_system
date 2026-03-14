class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  def index
    authorize Course
    @courses = policy_scope(Course).by_name
  end

  def show
    authorize @course
    @enrollments = @course.enrollments.includes(:student).order("students.name")
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    authorize @course

    if @course.save
      redirect_to @course, notice: "Tạo môn học #{@course.code} thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to @course, notice: "Cập nhật môn học thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    course_name = @course.name
    @course.destroy
    redirect_to courses_path,
                notice: "Đã xóa môn #{course_name}. Các đăng ký liên quan cũng bị xóa.",
                status: :see_other
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :code, :description, :credits)
  end
end
