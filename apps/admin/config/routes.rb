# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/dashboard', to: 'dashboard#index', as: :dashboard

get '/setup', to: 'setup#index', as: :setup
post '/setup', to: 'setup#create'
get '/setup/done', to: 'setup#done', as: :setup_done

resource 'session', only: [:destroy, :create]

resource 'config', only: [:edit, :update]

resources 'providers' do
  resources 'params', only: [:index]
end

resources 'adapters', only: [:show] do
  resources 'params', only: [:index]
end

resources 'attrs', only: [:index, :create, :update, :destroy]

resources 'users', only: [:index, :show] do
  collection do
    get 'sync'
  end
  resource 'password', only: [:create]
end
