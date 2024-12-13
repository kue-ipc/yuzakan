# frozen_string_literal: true

module Admin
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/config", to: "config.show", as: :config
    get "/config/new", to: "config.new"
    get "/config/edit", to: "config.edit"
    post "/config", to: "config.create", as: :config
    patch "/config", to: "config.update", as: :config
    put "/config", to: "config.replace", as: :config

    get "/providers", to: "providers.index", as: :providers
    get "/providers/:id", to: "providers.show", as: :provider
    get "/providers/:id/export", to: "providers.export"

    get "/attrs", to: "attrs.index", as: :attrs

    get "/users", to: "users.index", as: :users
    get "/users/:id", to: "users.index", as: :user
    get "/users/:id/export", to: "users.export"

    get "/groups", to: "groups.index", as: :group
    get "/groups/:id", to: "groups.index", as: :groups
    get "/groups/:id/export", to: "groups.export"
  end
end
