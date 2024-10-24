Rails.application.routes.draw do
  get 'admin/index'
  devise_for :users
  resources :links
  resources :subscriptions
  resources :notifications
  resources :price_histories
  resources :products
  resources :categories
  resources :users

  resources :admin, only: [:index, :create, :update, :destroy]

  authenticated :user do
    root to: redirect('/categories'), as: :authenticated_root
  end

  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end

end
