# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Create
        include Admin::Action

        def call(params)
          result = UpdateProvider.new.call(params[:provider])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.path(:new_provider)
          end

          redirect_to routes.path(:providers)
        end
      end
    end
  end
end
