require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Index
        include Admin::Action
        expose :providers
        include Hanami::Action::Cache

        cache_control :no_store

        def call(_params)
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
