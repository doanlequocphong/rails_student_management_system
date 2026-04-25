class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :transcript]

  def index
    authorize Student
    @students = StudentQuery.new(policy_scope(Student))
                            .search(params[:q])
                            .with_classroom
                            .recent
                            .result
  end

  def show
    authorize @student
    @enrollments       = @student.enrollments.includes(:course).order("courses.name")
    enrolled_course_ids = @enrollments.map(&:course_id)
    @available_courses  = Course.by_name.where.not(id: enrolled_course_ids)
  end

  def transcript
    authorize @student, :transcript?
    calculator = GpaCalculatorService.new(student: @student).call
    query      = TranscriptQuery.new(@student)
    @presenter = StudentTranscriptPresenter.new(@student, calculator, query.grades_by_course)
  end

  def new
    @student = Student.new
    authorize @student
  end

  def create
    @student = Student.new(student_params)
    authorize @student

    if @student.save
      redirect_to @student, notice: "Tạo sinh viên thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @student
  end

  def update
    authorize @student
    if @student.update(student_params)
      redirect_to @student, notice: "Cập nhật sinh viên thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @student
    @student.destroy
    redirect_to students_path, notice: "Đã xóa sinh viên.", status: :see_other
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :phone, :date_of_birth, :address, :classroom_id)
  end
end
