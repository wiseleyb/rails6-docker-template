Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  get 'welcome/index'
  get 'welcome/react'

  resources :articles

  #------------------------------------------
  # Pusher Controller
  #------------------------------------------
  post 'pusher/auth' => 'pusher#auth'
  post 'pusher/webhooks' => 'pusher#webhooks'

  root 'welcome#index'
end
