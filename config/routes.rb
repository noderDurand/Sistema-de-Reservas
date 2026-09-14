Rails.application.routes.draw do
  namespace :admin do
    get "reservas/index"
    get "reservas/show"
    get "reservas/edit"
    get "turnos/index"
    get "turnos/show"
    get "turnos/new"
    get "turnos/edit"
    root "dashboard#index"

    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resources :canchas
    resources :turnos
    resources :reservas, only: [ :index, :show, :edit, :update ]
  end
end
