Rails.application.routes.draw do
  get 'users', to: 'admin#index', as: :users_panel
  devise_for :users
  resources :links
  resources :subscriptions
  resources :notifications
  resources :price_histories
  resources :products
  resources :categories, only: [:index, :show]
  resources :users

 
  get 'admin/categories', to: 'admin_categories#index', as: :categories_panel

  
  resources :admin_categories, only: [:index, :create, :update, :destroy]
  resources :admin, only: [:index, :create, :update, :destroy]

  authenticated :user do
    root to: redirect('/categories'), as: :authenticated_root
  end

  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end

  # Ruta para iniciar el scraping
  # config/routes.rb

  resources :categories do
    member do
      get :scrape # Esto crea una ruta para /categories/:id/scrape
    end
  end
  resources :products


end
