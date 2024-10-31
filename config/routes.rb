Rails.application.routes.draw do
  # Rutas de paneles de administración
  get 'users', to: 'admin#index', as: :users_panel
  get 'admin/categories', to: 'admin_categories#index', as: :categories_panel
  resources :admin, only: [:index, :create, :update, :destroy]
  resources :admin_categories, only: [:index, :create, :update, :destroy]

  # Rutas de Devise y autenticación
  devise_for :users
  post 'login', to: 'users#login'

  # Rutas de recursos
  resources :users, except: [:new, :edit] # Para autenticación JWT
  resources :links
  resources :subscriptions
  resources :notifications
  resources :price_histories
  resources :products
  resources :categories, only: [:index, :show] do
    member do
      get :scrape # Para /categories/:id/scrape
    end
  end

  # Redirecciones de rutas raíz según autenticación
  authenticated :user do
    root to: redirect('/categories'), as: :authenticated_root
  end
  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end
end