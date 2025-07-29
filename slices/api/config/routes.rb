# frozen_string_literal: true

module API
  class Routes < Hanami::Routes
    get "/adapters", to: "adapters.index"
    get "/adapters/:id", to: "adapters.show"

    get "/affiliations", to: "affiliations.index"
    post "/affiliations", to: "affiliations.create"
    get "/affiliations/:id", to: "affiliations.show"
    patch "/affiliations/:id", to: "affiliations.update"
    delete "/affiliations/:id", to: "affiliations.destroy"

    get "/attrs", to: "attrs.index", as: :attrs
    post "/attrs", to: "attrs.create", as: :attrs
    get "/attrs/:id", to: "attrs.show", as: :attr
    patch "/attrs/:id", to: "attrs.update", as: :attr
    delete "/attrs/:id", to: "attrs.destroy", as: :attr

    post "/auth", to: "auth.create", as: :auth
    get "/auth", to: "auth.show", as: :auth
    delete "/auth", to: "auth.destroy", as: :auth

    post "/auth/mfa", to: "auth.mfa.create", as: :auth_mfa
    get "/auth/mfa", to: "auth.mfa.show", as: :auth_mfa

    get "/config", to: "config.show", as: :config
    patch "/config", to: "config.update", as: :config

    get "/groups", to: "groups.index", as: :groups
    post "/groups", to: "groups.create", as: :groups
    get "/groups/:id", to: "groups.show", as: :group
    patch "/groups/:id", to: "groups.update", as: :group
    delete "/groups/:id", to: "groups.destroy", as: :group

    get "/services", to: "services.index", as: :services
    post "/services", to: "services.create", as: :services
    get "/services/:id", to: "services.show", as: :service
    patch "/services/:id", to: "services.update", as: :service
    delete "/services/:id", to: "services.destroy", as: :service

    get "/services/:id/check", to: "services.check", as: :service_check

    get "/session", to: "session.show", as: :session

    get "/system", to: "system.show", as: :session

    get "/users", to: "users.index", as: :users
    post "/users", to: "users.create", as: :users
    get "/users/:id", to: "users.show", as: :user
    patch "/users/:id", to: "users.update", as: :user
    delete "/users/:id", to: "users.destroy", as: :user

    post "/users/:id/lock", to: "users/lock.create", as: :user_lock
    delete "/users/:id/lock", to: "users/lock.destroy", as: :user_lock
    post "/users/:id/password", to: "users/password.create", as: :user_password
    patch "/users/:id/password", to: "users.password.update", as: :user_password

    post "/users/:id/mfa/code", to: "users/mfa/code.create", as: :user_mfa_code
    get "/users/:id/mfa/code", to: "users/mfa/code.show", as: :user_mfa_code
    # patch "/users/:id/mfa/code", to: "users/mfa/code.update", as: :user_mfa_code
    delete "/users/:id/mfa/code", to: "users/mfa/code.destroy", as: :user_mfa_code

    post "/users/:id/mfa/email", to: "users/mfa/email.create", as: :user_mfa_email
    get "/users/:id/mfa/email", to: "users/mfa/email.show", as: :user_mfa_email
    # patch "/users/:id/mfa/email", to: "users/mfa/email.update", as: :user_mfa_email
    delete "/users/:id/mfa/email", to: "users/mfa/email.destroy", as: :user_mfa_email

    post "/users/:id/mfa/totp", to: "users/mfa/totp.create", as: :user_mfa_totp
    get "/users/:id/mfa/totp", to: "users/mfa/totp.show", as: :user_mfa_totp
    patch "/users/:id/mfa/totp", to: "users/mfa/totp.update", as: :user_mfa_totp
    delete "/users/:id/mfa/totp", to: "users/mfa/totp.destroy", as: :user_mfa_totp
  end
end
