Rails.application.routes.draw do
  namespace :events do
    resources :involvements
  end
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#show", slug: "welcome"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :sponsors, path: "" do
    resources :sponsorships
    resources :sponsor_tiers
  end
  namespace :talks, path: "" do
    resources :speaker_talks
    resources :talks
  end
  namespace :events, path: "" do
    resources :cfps
    resources :events
    resources :participations
    resources :series
  end
  namespace :entities, path: "" do
    resources :organizations
    resources :people
  end
  namespace :venues, path: "" do
    resources :venues
  end
  namespace :locations, path: "" do
    resources :addresses
    resources :cities
    resources :coordinates
    resources :maps
  end

  # frozen:md
  constraints slug: Regexp.union(Category.all.map(&:slug)) do
    resources :categories, param: :slug, only: [ :index, :show ]
  end
  resources :pages, param: :slug, only: [ :show ]

  # frozen:db
  if defined?(Avo)
    mount_avo at: "/avo"
  end

  # frozen:ui
  if Rails.env.local?
    mount Lookbook::Engine, at: "/lookbook"
    resources :jasmine, only: [ :index ]
  end
end
