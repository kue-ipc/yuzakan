# frozen_string_literal: true

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/about", to: "about.index", as: :about
    get "/about/browser", to: "about.browser", as: :about_browser

    get "/user", to: "user.show", as: :user
    get "/password/!", to: "password.edit", as: :edit_password
    get "/providers/:id", to: "providers.show", as: :provider

    slice :admin, at: "/admin"

    slice :api, at: "/api"
    get "/user/:id", to: "user.show"
  end
end
