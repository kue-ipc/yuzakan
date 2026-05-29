# frozen_string_literal: true

# haccking routers
Hanami::Slice::Router::ResourceBuilder::ROUTE_OPTIONS[:new][:path_suffix] = "/\\*"
Hanami::Slice::Router::ResourceBuilder::ROUTE_OPTIONS[:edit][:path_suffix] = "/:id/!"

module Admin
  class Routes < Hanami::Routes
    root to: "home.index"

    resource :config, only: [:show] do
      put "/all", to: "config.export", as: :all
      get "/all", to: "config.import", as: :all
    end

    resources :services, only: [:index, :show]

    resources :attrs, only: [:index]

    resources :users, only: [:index, :new, :show]

    # TODO: groupにもnewを作る？
    resources :groups, only: [:index, :show]
  end
end
