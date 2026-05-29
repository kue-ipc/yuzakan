# frozen_string_literal: true

# haccking routers
Hanami::Slice::Router::ResourceBuilder::ROUTE_OPTIONS[:new][:path_suffix] = "/\\*"
Hanami::Slice::Router::ResourceBuilder::ROUTE_OPTIONS[:edit][:path_suffix] = "/:id/!"

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/about", to: "about.index", as: :about
    get "/about/browser", to: "about.browser", as: :about_browser

    resource :user, only: [:show]
    resource :password, only: [:edit]
    resources :services, only: [:show]

    slice :admin, at: "/admin"

    slice :api, at: "/api"
  end
end
