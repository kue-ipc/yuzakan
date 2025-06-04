# frozen_string_literal: true

module API
  class Routes < Hanami::Routes
    post "/auth", to: "auth.create", as: :auth
    delete "/auth", to: "auth.destroy", as: :auth
    get "/auth", to: "auth.show", as: :auth

    get "/config", to: "config.show", as: :config
    patch "/config", to: "config.update", as: :config

    # get "/adapters", to: "adapters.index", as: :adapters
    # get "/adapters/:id", to: "adapters.show", as: :adapter

    # get "/attrs", to: "attrs.index", as: :attrs
    # post "/attrs", to: "attrs.create", as: :attrs
    # get "/attrs/:id", to: "attrs.show", as: :attr
    # patch "/attrs/:id", to: "attrs.update", as: :attr
    # delete "/attrs/:id", to: "attrs.destroy", as: :attr

    # TODO: わけずにユーザーの処理にする
    # resource :self, only: [:show] do
    #   resource :password, only: [:update]
    #   resources :providers, only: [:show, :create, :destroy] do
    #     resource :password, only: [:create]
    #     resource :code, only: [:create]
    #     resource :lock, only: [:destroy]
    #   end
    # end

    # get "/providers", to: "providers.index", as: :providers
    # post "/providers", to: "providers.create", as: :providers
    # get "/providers/:id", to: "providers.show", as: :provider
    # patch "/providers/:id", to: "providers.update", as: :provider
    # delete "/providers/:id", to: "providers.destroy", as: :provider
    # get "/providers/:id/check", to: "providers.check"

    get "/session", to: "session.show", as: :session

    post "/mfa/email", to: "mfa.email.create", as: :mfa_email
    delete "/mfa/email", to: "mfa.email.destroy", as: :mfa_email
    patch "/mfa/email", to: "mfa.email.update", as: :mfa_email

    # get "/users", to: "users.index", as: :users
    # post "/users", to: "users.create", as: :users
    # get "/users/:id", to: "users.show", as: :user
    # patch "/users/:id", to: "users.update", as: :user
    # delete "/users/:id", to: "users.destroy", as: :user
    # post "/users/:id/password", to: "users/password.create", as: :user_password
    patch "/users/:id/password", to: "users.password.update", as: :user_password
    # post "/users/:id/lock", to: "users/lock.create", as: :user_lock
    # delete "/users/:id/lock", to: "users/lock.destroy", as: :user_lock

    # get "/groups", to: "groups.index", as: :groups
    # get "/groups/:id", to: "groups.show", as: :group
    # patch "/groups/:id", to: "groups.update", as: :group
    # get "/groups/:id/members", to: "groups/members.index", as: :group_members
    # patch "/groups/:id/members/:user_id", to: "groups/members.update",
    #   as: :group_member
    # delete "/groups/:id/members/:user_id", to: "groups/members.destroy",
    #   as: :group_member

    # get "/system", to: "system.show", as: :system

    # get "/menus", to: "menus.index", as: :menus
    #
    # patch "/password", to: "password.update", as: :password
    # post "/providers/:id", to: "providers.create", as: :provider
    # delete "/providers/:id", to: "providers.destroy", as: :provider
    # post "/providers/:id/code", to: "providers/code.create", as: :provider_code
    # post "/providers/:id/password", to: "providers/password.create",
    #   as: :provider_password
    # delete "/providers/:id/lock", to: "providers/lock.destroy",
    #   as: :provider_lock
  end
end
