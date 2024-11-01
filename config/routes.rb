Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get 'users', to: 'admin#index', as: :users_panel
  devise_for :users, controllers: { invitations: 'devise/invitations' }
  resources :links
  resources :subscriptions
  resources :notifications
  resources :price_histories
  resources :products
  resources :users

  devise_for :users
  post 'login', to: 'users#login'

  authenticated :user do
    resources :categories do
      member do
        get :scrape # Ruta para el scraping
      end

      # Rutas anidadas para productos, accesibles solo por usuarios autenticados
      resources :products, only: [:index] # Esto crea la ruta /categories/:category_id/products
    end

    root to: redirect('/categories'), as: :authenticated_root
  end

  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end

  get 'admin/categories', to: 'admin_categories#index', as: :categories_panel

  resources :admin_categories, only: [:index, :create, :update, :destroy]
  resources :admin, only: [:index, :create, :update, :destroy]
end
