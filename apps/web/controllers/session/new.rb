# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class New
        include Web::Action

        def call(params)
          if authenticated?
            redirect_to routes.path(:dashboard)
          end
        end

        private

        def authenticate!; end
      end
    end
  end
end
