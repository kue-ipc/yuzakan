root to: 'home#index'

get '/about', to: 'about#index', as: 'about'

get '/dashboard', to: 'dashboard#index', as: 'dashboard'

resource 'session', only: [:create, :destroy]

resource 'user', only: [] do
  resource 'password', only: [:edit, :update]
end
