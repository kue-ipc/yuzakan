resource 'session', only: [:destroy, :create]
resource 'account', only: [:show] do
  # resource 'password', only: [:edit, :update]
end
