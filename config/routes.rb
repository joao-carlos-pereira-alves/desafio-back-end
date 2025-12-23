Rails.application.routes.draw do
  resources :entities_users
  resources :entities
  namespace :api do
    namespace :v1 do
      resources :registrations, only: %i[create index]
    end
  end
end
