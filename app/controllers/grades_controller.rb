class GradesController < ApplicationController
  before_action :set_course
  before_action :set_grade, only: [:update, :destroy]

  # GET /courses/:course_id/grades
  # Trang nhập điểm — bảng tất cả sinh viên đăng ký môn này
  def index
    # Sinh viên đã đăng ký môn này, sắp xếp theo tên
    @students = @course.students.by_name

    # Điểm hiện có của tất cả sinh viên trong môn này
    # group_by: nhóm grades theo student_id để dễ tra cứu trong view
    @grades_by_student = @course.grades
                                .includes(:student)
                                .group_by(&:student_id)

    # Object mới để dùng cho form create
    @grade = Grade.new
  end

  # POST /courses/:course_id/grades
  # Lưu 1 điểm mới
  def create
    @grade = Grade.new(grade_params)
    @grade.course = @course

    if @grade.save
      redirect_to course_grades_path(@course),
                  notice: "Đã lưu điểm #{@grade.score} cho #{@grade.student.name}."
    else
      # Load lại data để render index
      @students = @course.students.by_name
      @grades_by_student = @course.grades.includes(:student).group_by(&:student_id)
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH /courses/:course_id/grades/:id
  # Cập nhật điểm đã có
  def update
    if @grade.update(grade_params.except(:student_id))
      redirect_to course_grades_path(@course),
                  notice: "Đã cập nhật điểm thành #{@grade.score}."
    else
      redirect_to course_grades_path(@course),
                  alert: @grade.errors.full_messages.first
    end
  end

  # DELETE /courses/:course_id/grades/:id
  def destroy
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
    # Scoped finder: chỉ tìm grade thuộc course này
    @grade = @course.grades.find(params[:id])
  end

  def grade_params
    params.require(:grade).permit(:student_id, :score, :grade_type, :comment)
  end
end
