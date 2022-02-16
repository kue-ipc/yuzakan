resource 'session', only: [:destroy, :create]
resource 'current_user', only: [:show] do
  # resource 'password', only: [:edit, :update]
end
resources 'adapters', only: [:index, :show] do
  resources 'param_types', only: [:index]
end

# get '/current_user/:id', to: 'current_user#show'
# get '/adapters', to: 'adapters#index'
# get '/adapters/:id', to: 'adapters#show'
# get '/adapters/param_types', to: 'adapters/param_types#index'
