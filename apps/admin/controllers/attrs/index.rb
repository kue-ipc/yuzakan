require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Index
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :attrs
        expose :providers

        def initialize(attr_repository: AttrRepository.new, provider_repository: ProviderRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
          @provider_repository = provider_repository
        end

        def call(_params)
          @attrs = AttrRepository.new.all_with_mappings
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
