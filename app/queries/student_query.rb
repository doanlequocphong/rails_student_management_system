class StudentQuery
  def initialize(scope = Student.all)
    @scope = scope
  end

  def call
    @scope
  end

  def search(term)
    return self if term.blank?
    @scope = @scope.where('name ILIKE :q OR email ILIKE :q', q: "%#{term}%")
    self
  end

  def with_classroom
    @scope = @scope.includes(:classroom)
    self
  end

  def recent
    @scope = @scope.order(created_at: :desc)
    self
  end

  def result
    @scope
  end
end
