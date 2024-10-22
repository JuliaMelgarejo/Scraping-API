Rails.application.routes.draw do
  devise_for :users
  resources :links
  resources :subscriptions
  resources :notifications
  resources :price_histories
  resources :products
  resources :categories
  resources :users
  authenticated :user do
    root to: redirect('/products'), as: :authenticated_root
  end

  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
