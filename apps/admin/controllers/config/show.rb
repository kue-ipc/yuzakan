# frozen_string_literal: true

module Admin
  module Controllers
    module Config
      class Show
        include Admin::Action

        expose :attrs
        expose :providers

        def initialize(attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @attr_repository ||= attr_repository
          @provider_repository ||= provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.format = :yml

          @attrs = @attr_repository.ordered_all_with_mappings
          @providers = @provider_repository.ordered_all_with_adapter
        end
      end
    end
  end
end
