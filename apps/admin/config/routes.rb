# frozen_string_literal: true

root to: 'home#index'

resource :config, only: [:show, :new, :create, :edit, :update]
put 'config', to: 'config#replace', as: :config

resources :providers, only: [:index, :show]

resources :attrs, only: [:index]

resources :users, only: [:index, :show]

resources :groups, only: [:index, :show]
