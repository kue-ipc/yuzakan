# frozen_string_literal: true

require_relative "entity_service"

module API
  module Actions
    module Services
      module SetService
        include EntityService

        def self.included(action)
          action.class_eval do
            params IdParams
            before :set_service
          end
        end

        def initialize(service_repository: ServiceRepository.new, **opts)
          super
          @service_repository ||= service_repository
        end

        private def set_service
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          @name = params[:id]
          load_service

          halt_json 404 if @service.nil?
        end
      end
    end
  end
end
