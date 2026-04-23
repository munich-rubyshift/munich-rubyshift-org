Rails.application.routes.draw do
  namespace :entities do
    resources :organizations
    resources :people
  end
  namespace :venues do
    resources :venues
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "pages#show", slug: "welcome"

  # frozen:md
  constraints slug: Regexp.union(Category.all.map(&:slug)) do
    resources :categories, param: :slug, only: [ :index, :show ]
  end
  resources :pages, param: :slug, only: [ :show ]

  # frozen:db
  if Rails.env.development?
    mount_avo at: "/avo"
  end

  # frozen:ui
  if Rails.env.local?
    mount Lookbook::Engine, at: "/lookbook"
    resources :jasmine, only: [ :index ]
  end
end
