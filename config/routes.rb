Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "pujas#index"  # show all pujas as home

  resources :pujas, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: [:new, :create] do
    get 'thank_you', on: :member
  end
end
