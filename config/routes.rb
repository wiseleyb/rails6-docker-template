Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'welcome/index'

  resources :articles

  root 'welcome#index'
end
