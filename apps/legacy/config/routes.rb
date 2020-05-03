# frozen_string_literal: true

root to: 'home#index'

get '/dashboard', to: 'dashboard#index'
get '/about', to: 'about#index'

resource 'session', only: [:create, :destroy]

resource 'user', only: [] do
  resource 'password', only: [:edit, :update]
end
