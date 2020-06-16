# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Show
        include Admin::Action

        expose :provider

        def call(params)
          provider_repository = ProviderRepository.new
          @provider = provider_repository.find_with_params(params[:id].to_i)
        end
      end
    end
  end
end
