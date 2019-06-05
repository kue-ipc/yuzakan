# frozen_string_literal: true

# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/dashboard', to: 'dashboard#index', as: :dashboard
get '/login', to: 'session#new'
get '/logout', to: 'session#destroy'
resource 'session', only: [:new, :destroy, :create]
resource 'user', only: [] do
  resource 'password', only: [:edit, :update]
end
