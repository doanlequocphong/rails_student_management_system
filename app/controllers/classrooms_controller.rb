class ClassroomsController < ApplicationController
  before_action :set_classroom, only: [:show, :edit, :update, :destroy, :assign_student, :remove_student]

  def index
    authorize Classroom
    @classrooms = policy_scope(Classroom).with_students_count.recent
  end

  def show
    authorize @classroom
    @students            = @classroom.students.by_name
    @unassigned_students = Student.where(classroom_id: nil).by_name
  end

  def new
    @classroom = Classroom.new
    authorize @classroom
  end

  def create
    @classroom = Classroom.new(classroom_params)
    authorize @classroom

    if @classroom.save
      redirect_to @classroom, notice: "Tạo lớp học thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @classroom
  end

  def update
    authorize @classroom
    if @classroom.update(classroom_params)
      redirect_to @classroom, notice: "Cập nhật lớp học thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def assign_student
    authorize @classroom, :assign_student?
    student = Student.find(params[:student_id])
    service = ClassroomAssignmentService.new(classroom: @classroom, student: student).call.assign!

    redirect_to @classroom,
      notice: (service.success? ? "Đã thêm #{student.name} vào lớp #{@classroom.name}." : service.error)
  end

  def remove_student
    authorize @classroom, :remove_student?
    student = Student.find(params[:student_id])
    service = ClassroomAssignmentService.new(classroom: @classroom, student: student).call.remove!

    redirect_to @classroom,
      notice: (service.success? ? "Đã xóa #{student.name} khỏi lớp." : service.error),
      status: :see_other
  end

  def destroy
    authorize @classroom
    @classroom.destroy
    redirect_to classrooms_path, notice: "Đã xóa lớp học.", status: :see_other
  end

  private

  def set_classroom
    @classroom = Classroom.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :description, :academic_year)
  end
end
