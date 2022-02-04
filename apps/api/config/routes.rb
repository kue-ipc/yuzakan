resource 'session', only: [:destroy, :create]
resource 'current_user', only: [:show] do
  # resource 'password', only: [:edit, :update]
end
# get '/current_user/:id', to: 'current_user#show'
