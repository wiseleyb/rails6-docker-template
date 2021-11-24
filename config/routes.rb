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

  resources :articles

  root 'welcome#index'
end
