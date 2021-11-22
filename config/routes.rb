Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users

  get 'welcome/index'

  resources :articles

  root 'welcome#index'
end
