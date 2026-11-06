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

  # Destino del QR: público (lo abre el celular, sin token). Al abrirlo el
  # pago simulado queda aprobado.
  get "pagos/:token", to: "pagos#show", as: :pago_publico

  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      post "signup", to: "sessions#signup"
      delete "logout", to: "sessions#destroy"

      resources :canchas, only: [ :index, :show ] do
        member do
          get :turnos_disponibles
        end
      end

      resources :reservas, only: [ :index, :show, :create ] do
        member do
          patch :cancelar
        end
      end

      get "profile", to: "profiles#show"
    end
  end
end
