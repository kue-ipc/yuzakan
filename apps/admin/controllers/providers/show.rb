# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Show
        include Admin::Action

        expose :provider

        def call(params)
          result = CheckProvider.new.call(provider_id: params[:id])
          if result.successful?
            @provider = result.provider
          else
            flash[:errors] = result.errors
          end
        end
      end
    end
  end
end
