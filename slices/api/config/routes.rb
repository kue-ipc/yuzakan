# frozen_string_literal: true

module API
  class Routes < Hanami::Routes
    resources :adapters, only: [:index, :show]

    resources :affiliations, only: [:index, :create, :show, :update, :destroy]

    resources :attrs, only: [:index, :create, :show, :update, :destroy]

    resource :auth, only: [:create, :show, :destroy] do
      resource :mfa, only: [:create, :show]
    end

    resource :config, only: [:show, :update]

    resources :groups, only: [:index, :create, :show, :update, :destroy]

    resources :services, only: [:index, :create, :show, :update, :destroy] do
      get "/check", to: "services.check", as: :check
    end

    resource :session, only: [:show]

    resource :system, only: [:show]

    resources :users, only: [:index, :create, :show, :update, :destroy] do
      # resource :lock, only: [:create, :destroy]
      # resource :password, only: [:create, :update]
      resource :password, only: [:update]
      # resource :mfa do
      #   resource :code, only: [:create, :show, :update, :destroy]
      #   resource :email, only: [:create, :show, :update, :destroy]
      #   resource :totp, only: [:create, :show, :update, :destroy]
      # end
    end
  end
end
