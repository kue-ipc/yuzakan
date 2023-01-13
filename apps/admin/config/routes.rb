# frozen_string_literal: true

root to: 'home#index'

resource :setup, only: [:show, :create]

resource :config, only: [:show, :new, :create, :edit, :update] do
  member do
    post 'import'
    get 'export'
  end
end
put 'config', to: 'config#replace', as: :config

resources :providers, only: [:index, :show]

resources :attrs, only: [:index]

resources :users, only: [:index, :show]

resources :groups, only: [:index, :show]
