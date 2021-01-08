# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Show
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :provider

        def call(params)
          provider_repository = ProviderRepository.new
          @provider = provider_repository.find_with_params(params[:id].to_i)
        end
      end
    end
  end
end
