# frozen_string_literal: true

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/about", to: "about.index", as: :about
    get "/about/browser", to: "about.browser", as: :about_browser

    get "/locale", to: "locale.index"

    # TODO: 実装がまだのため、コメントアウトしておく
    # slice :admin, at: "/admin"
    # slice :api, at: "/api"
    # slice :user, at: "/user"
    # slice :vendor, at: "/vendor"
  end
end
