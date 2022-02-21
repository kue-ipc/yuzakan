resource :session, only: [:show, :create, :destroy]
resource :current_user, only: [:show] do
  resource :password, only: [:update]
end
resources :adapters, only: [:index, :show] do
  resources :param_types, only: [:index]
end

resources :providers, only: [:index, :show, :create, :update, :destroy] do
  resource :current_user, only: [:show, :create, :destroy] do
    resource :password, only: [:create]
    resource :code, only: [:create]
    resource :lock, only: [:destroy]
  end
end

resources :attrs, only: [:index, :show, :create, :update, :destroy]
