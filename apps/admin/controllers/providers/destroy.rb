# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Destroy
        include Admin::Action

        def call(params)
          id = params[:id]
          repo = ProviderRepository.new
          provider = repo.find(id)
          unless provider.immutable
            repo.delete(id)
          end
          redirect_to routes.providers_path
        end
      end
    end
  end
end
