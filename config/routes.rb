# frozen_string_literal: true

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/about", to: "about.index", as: :about
    get "/about/browser", to: "about.browser", as: :about_browser

    slice :admin, at: "/admin" do
      root to: "home.index"

      get "/config", to: "config.show"
      get "/config/new", to: "config.new"
      get "/config/edit", to: "config.edit"
      post "/config", to: "config.create"
      patch "/config", to: "config.update"
      put "/config", to: "config.replace", as: "config"

      get "/providers", to: "providers.index"
      get "/providers/:id", to: "providers.show"
      get "/providers/:id/export", to: "providers.export"

      get "/attrs", to: "attrs.index"

      get "/users", to: "users.index"
      get "/users/:id", to: "users.index"
      get "/users/:id/export", to: "users.export"

      get "/groups", to: "groups.index"
      get "/groups/:id", to: "groups.index"
      get "/groups/:id/export", to: "groups.export"
    end

    slice :api, at: "/api" do
      get "/adapters", to: "adapters.index"
      get "/adapters/:id", to: "adapters.show"

      get "/attrs", to: "attrs.index"
      get "/attrs/:id", to: "attrs.show"
      post "/attrs", to: "attrs.create"
      patch "/attrs/:id", to: "attrs.update"
      delete "/attrs/:id", to: "attrs.destroy"

      # TODO: わけずにユーザーの処理にする
      # resource :self, only: [:show] do
      #   resource :password, only: [:update]
      #   resources :providers, only: [:show, :create, :destroy] do
      #     resource :password, only: [:create]
      #     resource :code, only: [:create]
      #     resource :lock, only: [:destroy]
      #   end
      # end

      get "/providers", to: "providers.index"
      get "/providers/:id", to: "providers.show"
      post "/providers", to: "providers.create"
      patch "/providers/:id", to: "providers.update"
      delete "/providers/:id", to: "providers.destroy"
      get "/providers/:id/check", to: "providers.check"

      get "/session", to: "session.show"
      post "/session", to: "session.create"
      delete "/session", to: "session.destroy"

      get "/users", to: "users.index"
      get "/users/:id", to: "users.show"
      post "/users", to: "users.create"
      patch "/users/:id", to: "users.update"
      delete "/users/:id", to: "users.destroy"
      post "/users/:id/password", to: "users/password.create"
      post "/users/:id/lock", to: "users/lock.create"
      delete "/users/:id/lock", to: "users/lock.destroy"

      get "/groups", to: "groups.index"
      get "/groups/:id", to: "groups.show"
      patch "/groups/:id", to: "groups.update"
      get "/groups/:id/members", to: "groups/members.index"
      patch "/groups/:id/members/:user_id", to: "groups/members.update"
      delete "/groups/:id/members/:user_id", to: "groups/members.destroy"

      get "/system", to: "system.show"

      get "/menus", to: "menus.index"
    end

    slice :vendor, at: "/vendor" do
      root to: ->(_env) { [200, {}, [""]] }
    end

    slice :user, at: "/user" do
      root to: "home.index"
      # get "/user", to: "user.show"

      get "/password", to: "user/password.show"
      patch "/password", to: "user/password.update"
      # TODO: providerで汎用化
      # resource "google", only: [:show, :create, :destroy] do
      #   resource "code", only: [:create]
      #   resource "password", only: [:create]
      #   resource "lock", only: [:destroy]
      # end
      get "/providers/:id", to: "providers.show"
      get "/home", to: "home.index"
    end
  end
end
