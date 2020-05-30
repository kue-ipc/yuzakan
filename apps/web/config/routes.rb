# frozen_string_literal: true

# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/dashboard', to: 'dashboard#index', as: :dashboard

get '/maintenance', to: 'maintenance#index', as: :maintenance
get '/uninitialized', to: 'uninitialized#index', as: :uninitialized

resource 'session', only: [:destroy, :create]

resource 'user', only: [] do
  resource 'password', only: [:edit, :update]
end

get '/about', to: 'about#index', as: :about
get '/about/legacy', to: 'about#legacy', as: :about_legacy
