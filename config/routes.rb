Rails.application.routes.draw do
  resources :features
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :helps
  resources :accounts
  devise_for :users
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)
  resources :faqs
  resources :feedbacks
  resources :blogs
  resources :banners
  resources :services
  resources :abouts
  resources :headers
  resources :welcomes
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  authenticated :user do
    root 'accounts#index', as: "authenticated_root"
  end
    root "welcomes#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
