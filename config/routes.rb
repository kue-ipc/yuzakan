# frozen_string_literal: true

module Yuzakan
  class Routes < Hanami::Routes
    root to: "home#index"
    resource "user", only: [:show] do
      resource "password", only: [:edit, :update]
    end
    get "/about", to: "about#index", as: :about
    get "/about/browser", to: "about#browser", as: :about_browser
    resource "google", only: [:show, :create, :destroy] do
      resource "code", only: [:create]
      resource "password", only: [:create]
      resource "lock", only: [:destroy]
    end
    resources "providers", only: [:show]
    resource "password", only: [:edit]

    slice :api, at: "/admin" do
      root to: "home#index"
      resource :config, only: [:show, :new, :create, :edit, :update]
      put "config", to: "config#replace", as: :config
      resources :providers, only: [:index, :show] do
        member do
          get "export"
        end
      end
      resources :attrs, only: [:index]
      resources :users, only: [:index, :show] do
        collection do
          get "export"
        end
      end
      resources :groups, only: [:index, :show] do
        collection do
          get "export"
        end
      end
    end

    slice :api, at: "/api" do
      resources :adapters, only: [:index, :show]
      resources :attrs, only: [:index, :show, :create, :update, :destroy]
      resource :self, only: [:show] do
        resource :password, only: [:update]
        resources :providers, only: [:show, :create, :destroy] do
          resource :password, only: [:create]
          resource :code, only: [:create]
          resource :lock, only: [:destroy]
        end
      end
      resources :providers, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :check
        end
      end
      resource :session, only: [:show, :create, :destroy]
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        resource :password, only: [:create]
        resource :lock, only: [:create, :destroy]
      end
      resources :groups, only: [:index, :show, :update] do
        resources :members, only: [:index, :update, :destroy]
      end
      resource :system, only: [:show]
      resources :menus, only: [:index]
    end

    slice :api, at: "/vendor" do
      root to: ->(_env) { [200, {}, [""]] }
    end
  end
end
