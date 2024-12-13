# frozen_string_literal: true

module User
  class Routes < Hanami::Routes
    root to: "home.index"
    # get "/user", to: "user.show"

    get "/password", to: "user/password.show", as: :password
    patch "/password", to: "user/password.update", as: :password
    get "/providers/:id", to: "providers.show", as: :provider
    post "/providers/:id", to: "providers.create", as: :provider
    delete "/providers/:id", to: "providers.destroy", as: :provider
    post "/providers/:id/code", to: "providers/code.create", as: :provider_code
    post "/providers/:id/password", to: "providers/password.create", as: :provider_password
    delete "/providers/:id/lock", to: "providers/lock.destroy", as: :provider_lock
  end
end
