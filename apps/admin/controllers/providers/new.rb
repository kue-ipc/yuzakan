require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class New
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :provider

        def call(_params)
          @provider = nil
        end
      end
    end
  end
end
