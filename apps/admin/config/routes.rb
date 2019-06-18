# frozen_string_literal: true

# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/setup', to: 'setup#index', as: :setup
post '/setup', to: 'setup#create'
get '/setup/done', to: 'setup#done', as: :setup_done
resources 'providers'
resources 'adapters', only: [:show] do
  resources 'params', only: [:index]
end
resource 'session', only: %i[new destroy create]
get '/dashboard', to: 'dashboard#index', as: :dashboard
