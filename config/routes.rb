Rails.application.routes.draw do
  root "dashboard#show"

  resources :sales, only: :index, defaults: { format: :json }
  resources :arrondissements, only: %i[index show]
  resources :dvf_imports, only: :create

  get "up" => "rails/health#show", as: :rails_health_check
end
