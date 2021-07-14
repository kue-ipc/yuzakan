module Admin
  module Controllers
    module Config
      class Export
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :providers
        expose :attrs

        def call(_params)
          self.format = :yml

          @providers = ProviderRepository.new.all_with_adapter
          @attrs = AttrRepository.new.all_with_mappings
        end
      end
    end
  end
end
