class StudentsController < ApplicationController
  # before_action: chạy trước các action chỉ định
  # Tránh lặp code tìm @student ở show, edit, update, destroy
  before_action :set_student, only: [:show, :edit, :update, :destroy, :transcript]

  # GET /students
  # Lấy danh sách tất cả sinh viên
  def index
    @students = Student.recent
  end

  # GET /students/:id
  # Xem chi tiết 1 sinh viên (set bởi before_action)
  def show
    # Danh sách môn đang học (kèm enrollment để đọc grade)
    @enrollments = @student.enrollments.includes(:course).order("courses.name")
    # Môn học chưa đăng ký — dùng cho dropdown
    enrolled_course_ids = @enrollments.map(&:course_id)
    @available_courses  = Course.by_name.where.not(id: enrolled_course_ids)
  end

  # GET /students/:id/transcript
  # Bảng điểm tổng hợp — read-only
  def transcript
    # Enrollments + courses (eager load để tránh N+1)
    @enrollments = @student.enrollments
                           .includes(:course)
                           .order("courses.name")

    # Tất cả grades của sinh viên, group theo course để tra cứu nhanh
    @grades_by_course = @student.grades
                                .includes(:course)
                                .group_by(&:course_id)
  end

  # GET /students/new
  # Hiển thị form tạo sinh viên mới
  def new
    @student = Student.new
  end

  # POST /students
  # Nhận form data, lưu vào database
  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: "Tạo sinh viên thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /students/:id/edit
  # Hiển thị form chỉnh sửa (set bởi before_action)
  def edit
  end

  # PATCH /students/:id
  # Nhận form data, cập nhật vào database
  def update
    if @student.update(student_params)
      redirect_to @student, notice: "Cập nhật sinh viên thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /students/:id
  # Xóa sinh viên khỏi database
  def destroy
    @student.destroy
    redirect_to students_path, notice: "Đã xóa sinh viên.", status: :see_other
  end

  private

  # Tìm @student theo :id trong URL — dùng chung cho show/edit/update/destroy
  def set_student
    @student = Student.find(params[:id])
  end

  # Strong Parameters — chỉ cho phép đúng fields, chống Mass Assignment Attack
  def student_params
    params.require(:student).permit(:name, :email, :phone, :date_of_birth, :address, :classroom_id)
  end
end
