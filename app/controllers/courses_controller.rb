class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  def index
    @courses = Course.by_name
  end

  # GET /courses/:id
  def show
    # Lấy enrollments kèm student — tránh N+1
    @enrollments = @course.enrollments.includes(:student).order("students.name")
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: "Tạo môn học #{@course.code} thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /courses/:id/edit
  def edit
  end

  # PATCH /courses/:id
  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Cập nhật môn học thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /courses/:id
  def destroy
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
