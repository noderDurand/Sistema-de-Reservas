Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#index"

    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resources :canchas
    resources :turnos
    resources :reservas, only: [ :index, :show, :edit, :update ]
  end

  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      post "signup", to: "sessions#signup"

      resources :canchas, only: [ :index, :show ] do
        member do
          get :turnos_disponibles
        end
      end

      resources :reservas, only: [ :index, :show, :create ]

      get "profile", to: "profiles#show"
    end
  end
end
