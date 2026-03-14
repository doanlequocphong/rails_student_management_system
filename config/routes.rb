Rails.application.routes.draw do
  # Trang chủ "/" → HomeController#index
  root "home#index"

  # RESTful routes cho Students (7 routes cùng lúc)
  resources :students

  # RESTful routes cho Classrooms (sẽ dùng ở task sau)
  # resources :classrooms

  # Health check endpoint (Rails built-in)
  get "up" => "rails/health#show", as: :rails_health_check
end
