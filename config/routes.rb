require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :speakers, only: [:index, :show] do
    collection do
      post :rescan
    end

    member do
      post :play
    end
  end

  post :mute, to: 'welcome#mute'
  post :unmute, to: 'welcome#unmute'

  root to: 'welcome#index'
end
