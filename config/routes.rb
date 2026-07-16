Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "home#index"

  get "/about", to: "pages#about"
  get "/services", to: "pages#services"
  get "/contact", to: "pages#contact"

  resources :pujas, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end

  resources :temples, only: [:index, :show]

  resources :custom_bookings, only: [:new, :create] do
    member do
      get :thank_you
    end
  end

  get "bookings/:id/thank_you", to: "bookings#thank_you", as: "thank_you_booking"

  namespace :api do
    namespace :v1 do
      resources :pujas, only: [:index, :show]
      resources :temples, only: [:index, :show]
      resources :bookings, only: [:create]
      resources :custom_bookings, only: [:create]
      get 'home', to: 'home#index'
    end
  end
end
