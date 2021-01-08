# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Destroy
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          id = params[:id]
          repo = ProviderRepository.new
          provider = repo.find(id)
          repo.delete(id) unless provider.immutable
          redirect_to routes.providers_path
        end
      end
    end
  end
end
