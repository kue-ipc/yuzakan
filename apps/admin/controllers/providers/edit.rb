require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Edit
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :provider

        def call(params)
          @provider = ProviderRepository.new.find(params[:id])
        end
      end
    end
  end
end
