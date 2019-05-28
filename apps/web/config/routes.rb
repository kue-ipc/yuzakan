# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
root to: 'home#index'
get '/dashboard', to: 'dashboard#index'
get '/login', to: 'login#index'
get '/logout', to: 'logout#index'
get '/change_password', to: 'change_password#index'
