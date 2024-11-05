Rails.application.routes.draw do
  # Montar LetterOpener solo en el entorno de desarrollo
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Rutas de administración
  get 'users', to: 'admin#index', as: :users_panel
  get 'admin/categories', to: 'admin_categories#index', as: :categories_panel
  resources :admin_categories, only: [:index, :create, :update, :destroy]
  resources :admin, only: [:index, :create, :update, :destroy]

  # Rutas de usuarios
  devise_for :users, controllers: { invitations: 'devise/invitations' }
  resources :users

  # Rutas de enlaces y notificaciones
  resources :links
  resources :notifications
  resources :price_histories

  authenticated :user do
    # Rutas de categorías, accesibles solo por usuarios autenticados
    resources :categories do
      member do
        get :scrape # Ruta para el scraping
        post :subscribe, to: 'subscriptions#subscribe' # Ruta para la suscripción
      end

      # Rutas anidadas para productos, accesibles solo por usuarios autenticados
      resources :products, only: [:index] # Esto crea la ruta /categories/:category_id/products
    end

    # Rutas de productos
    resources :products do
      post 'send_test_notification', on: :member # Añade esta línea para la notificación de prueba
    end

    resources :subscriptions # Asegúrate de que existan rutas para suscripciones

    root to: redirect('/categories'), as: :authenticated_root
  end

  unauthenticated do
    root to: redirect('/users/sign_in'), as: :unauthenticated_root
  end
  namespace :api do
      post 'auth/register', to: 'api_user#register'
      post 'auth/login', to: 'api_user#login'
      put 'auth/subscription', to: 'api_user#subscription'
      get 'auth/subscription', to: 'api_user#subscription'
      delete 'auth/subscription', to: 'api_user#unsubscription'
      get 'auth/mysubscriptions', to: 'api_user#mysubscriptions'
    end
end
