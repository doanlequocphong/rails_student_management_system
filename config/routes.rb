Rails.application.routes.draw do
  # Trang chủ "/" → HomeController#index
  root "home#index"

  # RESTful routes cho Students + Enrollments lồng nhau (nested)
  resources :students do
    # only: giới hạn chỉ 3 actions — không cần index/show/new/edit riêng
    resources :enrollments, only: [:create, :update, :destroy]
  end

  # RESTful routes cho Classrooms + custom member actions
  resources :classrooms do
    member do
      # PATCH /classrooms/:id/assign_student  — gán sinh viên vào lớp
      patch :assign_student
      # DELETE /classrooms/:id/remove_student — xóa sinh viên khỏi lớp
      delete :remove_student
    end
  end

  # RESTful routes cho Courses + Grades lồng nhau
  resources :courses do
    resources :grades, only: [:index, :create, :update, :destroy]
  end

  # Health check endpoint (Rails built-in)
  get "up" => "rails/health#show", as: :rails_health_check
end
