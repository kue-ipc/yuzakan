# frozen_string_literal: true

module Yuzakan
  module Actions
    module Home
      class Index < Yuzakan::Action
        accept :html
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.body = Web::Views::Home::Login.render(exposures) unless authenticated?
        end
      end
    end
  end
end
