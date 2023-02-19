# frozen_string_literal: true

require_relative './entity_provider'

module Api
  module Controllers
    module Providers
      module SetProvider
        include EntityProvider

        def self.included(action)
          action.class_eval do
            params IdParams
            before :set_provider
          end
        end

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        private def set_provider
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          @provider_name = params[:id]
          load_provider

          halt_json 404 if @provider.nil?
        end
      end
    end
  end
end
