# frozen_string_literal: true

module Admin
  module Controllers
    module Home
      class Index
        include Admin::Action

        def call(_params)
          redirect_to routes.path(:dashboard) if authenticated?
        end

        def authenticate!; end
      end
    end
  end
end
