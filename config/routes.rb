Rails.application.routes.draw do
  devise_for :users
  # Trang chủ "/" → HomeController#index
  root "home#index"

  # RESTful routes cho Students + Enrollments lồng nhau (nested)
  resources :students do
    member do
      # GET /students/:id/transcript — bảng điểm sinh viên
      get :transcript
    end
    # only: giới hạn chỉ 2 actions — grade management dùng GradesController
    resources :enrollments, only: [:create, :destroy]
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

  # ── API v1 ────────────────────────────────────────────────────────
  # Tất cả API routes nằm dưới /api/v1/...
  # format: false → không cần .json trong URL (header Accept quyết định)
  namespace :api do
    namespace :v1 do
      resources :students, only: [:index, :show] do
        member do
          get :transcript
        end
      end
      resources :courses, only: [:index, :show] do
        resources :grades, only: [:index]
      end
      resources :classrooms, only: [:index, :show]
    end
  end

  # Health check endpoint (Rails built-in)
  get "up" => "rails/health#show", as: :rails_health_check
end
