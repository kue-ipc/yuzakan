# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Edit
        include Admin::Action
        expose :provider

        def call(params)
          @provider = ProviderRepository.new.find(params[:id])
        end
      end
    end
  end
end
