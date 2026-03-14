class StudentsController < ApplicationController
  # before_action: chạy trước các action chỉ định
  # Tránh lặp code tìm @student ở show, edit, update, destroy
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  # GET /students
  # Lấy danh sách tất cả sinh viên
  def index
    @students = Student.recent
  end

  # GET /students/:id
  # Xem chi tiết 1 sinh viên (set bởi before_action)
  def show
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
    params.require(:student).permit(:name, :email, :phone, :date_of_birth, :address)
  end
end
