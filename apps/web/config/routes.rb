# frozen_string_literal: true

# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/dashboard', to: 'dashboard#index', as: :dashboard
get '/change_password', to: 'change_password#index'
get '/login', to: 'session#new'
get '/logout', to: 'session#destroy'
resource 'session', only: [:new, :destroy, :create]
