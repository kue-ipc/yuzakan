# frozen_string_literal: true

module Admin
  module Actions
    module Config
      class Export < Admin::Action
        security_level 5

        def initialize(attr_repository: AttrRepository.new,
          service_repository: ServiceRepository.new,
          **opts)
          super
          @attr_repository ||= attr_repository
          @service_repository ||= service_repository
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.format = :yml

          @attrs = @attr_repository.ordered_all_with_mappings
          @services = @service_repository.ordered_all_with_adapter
        end
      end
    end
  end
end
