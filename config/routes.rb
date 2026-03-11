Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    confirmations: "users/confirmations",
    passwords: "users/passwords"
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
      resources :transactions, only: [ :index, :show, :create, :update, :destroy ]
      resources :categories, only: [ :index, :create, :update, :destroy ]
      resources :tags, only: [ :index, :create, :update, :destroy ]
      resources :payment_methods, only: [ :index, :create, :update, :destroy ]
      resource :dashboard, only: [ :show ], controller: "dashboard"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "health#show"

  get "/sw.js", to: proc { [ 404, {}, [ "" ] ] }

  root "home#index"
  get "*path", to: "home#index", constraints: ->(req) { !req.path.start_with?("/api") }
end
