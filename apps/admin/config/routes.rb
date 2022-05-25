root to: 'home#index'

resource :setup, only: [:show, :create]

resource :config, only: [:edit, :update] do
  member do
    post 'import'
    get 'export'
  end
end

resources :providers, only: [:index, :show]

resources :attrs, only: [:index]

resources :users, only: [:index, :show] do
  resource :password, only: [:create]
end

resources :groups, only: [:index]
