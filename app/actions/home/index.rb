# frozen_string_literal: true

module Yuzakan
  module Actions
    module Home
      class Index < Yuzakan::Action
        # security_level 0

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          # return if res[:current_user]

          # self.body = Web::Views::Home::Login.render(exposures)
        end
      end
    end
  end
end
