# frozen_string_literal: true

module Admin
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/config", to: "config.show", as: :config
    put "/config/all", to: "config.export", as: :config_all
    get "/config/all", to: "config.import", as: :config_all

    get "/providers", to: "providers.index", as: :providers
    get "/providers/:id", to: "providers.show", as: :provider

    get "/attrs", to: "attrs.index", as: :attrs

    get "/users", to: "users.index", as: :users
    get "/users/\\*", to: "users.new", as: :user_new
    get "/users/:id", to: "users.index", as: :user

    get "/groups", to: "groups.index", as: :groups
    get "/groups/:id", to: "groups.index", as: :group
  end
end
