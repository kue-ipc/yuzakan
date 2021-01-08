# frozen_string_literal: true

module Web
  module Controllers
    module Home
      class Index
        include Web::Action

        def call(_params)
          Hanami.logger.debug session.inspect
          redirect_to routes.path(:dashboard) if authenticated?
        end

        def authenticate!
        end
      end
    end
  end
end
