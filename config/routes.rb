Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  namespace :api do
    namespace :v1 do
      resources :daily_logs, only: [ :index, :show, :create ] do
        resources :meal_entries, only: [ :index, :show, :create, :update, :destroy ] do
          resources :meal_items, only: [ :index, :create, :destroy ] do
          end
        end
      end
      resources :food, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "/sw.js", to: proc { [ 404, {}, [ "" ] ] }

  root "home#index"
  get "*path", to: "home#index", constraints: ->(req) { !req.path.start_with?("/api") }
end
