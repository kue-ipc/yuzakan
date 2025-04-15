# frozen_string_literal: true

module Yuzakan
  module Actions
    module About
      class Browser < Yuzakan::Action
        security_level 0
        required_configuration false
        required_authentication false

        def handle(request, response)
        end
      end
    end
  end
end
