# frozen_string_literal: true

module API
  class Routes < Hanami::Routes
    resources :adapters, only: [:index, :show]

    resources :affiliations, only: [:index, :create, :show, :update, :destroy]

    # resources :attrs, only: [:index, :create, :show, :update, :destroy]

    get "/attrs/:category_id", to: "attrs.index", as: :attrs
    post "/attrs/:category_id", to: "attrs.create", as: :attrs
    get "/attrs/:category_id/:id", to: "attrs.show", as: :attr
    put "/attrs/:category_id/:id", to: "attrs.update", as: :attr
    delete "/attrs/:category_id/:id", to: "attrs.destroy", as: :attr

    resource :auth, only: [:create, :show, :destroy] do
      resource :mfa, only: [:create, :show]
    end

    resource :config, only: [:show, :update]

    resources :groups, only: [:index, :create, :show, :update, :destroy] do
      get "/sync", to: "groups.sync", as: :sync
    end

    resources :services, only: [:index, :create, :show, :update, :destroy] do
      get "/check", to: "services.check", as: :check
      resources :groups, only: [:create, :show, :update, :destroy]
      resources :users, only: [:create, :show, :update, :destroy] do
        resource :lock, only: [:create, :destroy]
        resource :password, only: [:create, :update]
        resource :mfa, only: [:destroy] do
          resource :code, only: [:create]
          # resource :email, only: [:create, :destroy]
          # resource :totp, only: [:create, :update, :destroy]
        end
      end
    end

    resource :session, only: [:show]

    resource :system, only: [:show]

    resources :users, only: [:index, :create, :show, :update, :destroy] do
      resource :lock, only: [:create, :destroy]
      resource :password, only: [:create, :update]
    end
  end
end
