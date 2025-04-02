Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  require 'sidekiq/web'
authenticate :admin_user do
  mount Sidekiq::Web => '/sidekiq'
end

  get "carts/show"

  resources :cart_items, only: [:create, :destroy]
  resource :cart, only: [:show]
resources :orders
  resources :products
  resources :categories do
    member do
        get :sub_categories
      end

  resources :sub_categories
    resources :products

  end
resources :sub_categories do
  resources :products

end
resources :wallets do
   get 'deposit', on: :member
   post 'process_deposit', on: :member, as: 'process_deposit'
 end
 resources :transactions, only: [:index, :show]  # Standalone transactions routes

 resources :wallets, only: [:show] do
  resources :transactions, only: [:new, :create] do
    collection do
      post 'orange_money_deposit', action: :create_orange_money_deposit
    end
  end
end

 resources :orders do
   post 'pay_with_wallet', on: :member
 end

  resources :supports
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

  # authenticated :user do
  #   root 'accounts#index', as: "authenticated_root"
  # end
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
