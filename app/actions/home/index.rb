# frozen_string_literal: true

module Yuzakan
  module Actions
    module Home
      class Index < Yuzakan::Action
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          return if response[:current_user]

          self.body = Web::Views::Home::Login.render(exposures)
        end
      end
    end
  end
end
