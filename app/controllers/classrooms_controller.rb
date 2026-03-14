class ClassroomsController < ApplicationController
  before_action :set_classroom, only: [:show, :edit, :update, :destroy, :assign_student, :remove_student]

  # GET /classrooms
  def index
    # with_students_count: scope tránh N+1 — đếm SV trong 1 query
    @classrooms = Classroom.with_students_count.recent
  end

  # GET /classrooms/:id
  def show
    # @classroom đã được set bởi before_action
    # Lấy danh sách sinh viên của lớp, sắp xếp theo tên
    @students = @classroom.students.by_name
    # Lấy sinh viên chưa được xếp lớp — dùng cho form assign
    @unassigned_students = Student.where(classroom_id: nil).by_name
  end

  # GET /classrooms/new
  def new
    @classroom = Classroom.new
  end

  # POST /classrooms
  def create
    @classroom = Classroom.new(classroom_params)

    if @classroom.save
      redirect_to @classroom, notice: "Tạo lớp học thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /classrooms/:id/edit
  def edit
  end

  # PATCH /classrooms/:id
  def update
    if @classroom.update(classroom_params)
      redirect_to @classroom, notice: "Cập nhật lớp học thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /classrooms/:id/assign_student
  # Gán sinh viên (params[:student_id]) vào lớp này
  def assign_student
    student = Student.find(params[:student_id])
    student.update!(classroom: @classroom)
    redirect_to @classroom, notice: "Đã thêm #{student.name} vào lớp #{@classroom.name}."
  rescue ActiveRecord::RecordNotFound
    redirect_to @classroom, alert: "Không tìm thấy sinh viên."
  end

  # DELETE /classrooms/:id/remove_student
  # Xóa sinh viên (params[:student_id]) khỏi lớp (set classroom_id = nil)
  def remove_student
    student = Student.find(params[:student_id])
    student.update!(classroom: nil)
    redirect_to @classroom, notice: "Đã xóa #{student.name} khỏi lớp.", status: :see_other
  rescue ActiveRecord::RecordNotFound
    redirect_to @classroom, alert: "Không tìm thấy sinh viên."
  end

  # DELETE /classrooms/:id
  def destroy
    @classroom.destroy
    redirect_to classrooms_path, notice: "Đã xóa lớp học.", status: :see_other
  end

  private

  def set_classroom
    @classroom = Classroom.find(params[:id])
  end

  # Strong Parameters — chỉ permit đúng fields
  def classroom_params
    params.require(:classroom).permit(:name, :description, :academic_year)
  end
end
