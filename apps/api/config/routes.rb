# frozen_string_literal: true

resources :adapters, only: [:index, :show]

resources :attrs, only: [:index, :show, :create, :update, :destroy]

resource :self, only: [:show] do
  resource :password, only: [:update]
  resources :providers, only: [:show, :create, :destroy] do
    resource :password, only: [:create]
    resource :code, only: [:create]
    resource :lock, only: [:destroy]
  end
end

resources :providers, only: [:index, :show, :create, :update, :destroy] do
  member do
    get :check
  end
end

resource :session, only: [:show, :create, :destroy]

resources :users, only: [:index, :show, :create, :update, :destroy] do
  resource :password, only: [:create]
  resource :lock, only: [:create, :destroy]
end

resources :groups, only: [:index, :show] do
  resources :members, only: [:index, :update, :destroy]
end

resource :system, only: [:show]

resources :menus, only: [:index]
