# frozen_string_literal: true

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/about", to: "about.index", as: :about
    get "/about/browser", to: "about.browser", as: :about_browser

    get "/user", to: "user.show", as: :user
    get "/password/!", to: "password.edit", as: :password_edit
    get "/services/:id", to: "services.show", as: :service

    slice :admin, at: "/admin"

    slice :api, at: "/api"
  end
end
