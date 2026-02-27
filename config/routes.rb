Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  get "/sw.js", to: proc { [ 404, {}, [ "" ] ] }

  root "home#index"
end
