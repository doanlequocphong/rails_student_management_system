Rails.application.routes.draw do
  # Trang chủ "/" → HomeController#index
  root "home#index"

  # RESTful routes cho Students (7 routes cùng lúc)
  resources :students

  # RESTful routes cho Classrooms + custom member actions
  resources :classrooms do
    member do
      # PATCH /classrooms/:id/assign_student  — gán sinh viên vào lớp
      patch :assign_student
      # DELETE /classrooms/:id/remove_student — xóa sinh viên khỏi lớp
      delete :remove_student
    end
  end

  # Health check endpoint (Rails built-in)
  get "up" => "rails/health#show", as: :rails_health_check
end
