module Admin
  module Controllers
    module Config
      class Export
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :providers
        expose :attrs

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.format = :yml

          @providers = ProviderRepository.new.ordered_all_with_adapter
          @attrs = AttrRepository.new.ordered_all_with_mappings
        end
      end
    end
  end
end
