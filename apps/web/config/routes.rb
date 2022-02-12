root to: 'home#index'

get '/maintenance', to: 'maintenance#index', as: :maintenance
get '/uninitialized', to: 'uninitialized#index', as: :uninitialized

resource 'user', only: [:show] do
  resource 'password', only: [:edit, :update]
end

get '/about', to: 'about#index', as: :about
get '/about/browser', to: 'about#browser', as: :about_browser

resource 'google', only: [:show, :create, :destroy] do
  resource 'code', only: [:create]
  resource 'password', only: [:create]
  resource 'lock', only: [:destroy]
end
