root to: 'home#index'

get '/setup', to: 'setup#index', as: :setup
post '/setup', to: 'setup#create'
get '/setup/done', to: 'setup#done', as: :setup_done

# resource :setup, only: [:show, :new, :create]

resource :config, only: [:edit, :update] do
  member do
    post 'import'
    get 'export'
  end
end

resources :providers, only: [:index, :show]

resources :attrs, only: [:index]

resources :users do
  collection do
    get 'search'
    get 'sync'
  end
  resource :password, only: [:create]
end
