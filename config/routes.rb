Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "pujas#index"

  get "/about", to: "pages#about"
  get "/services", to: "pages#services"
  get "/contact", to: "pages#contact"

  resources :pujas, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end

  get "bookings/:id/thank_you", to: "bookings#thank_you", as: "thank_you_booking"
end
