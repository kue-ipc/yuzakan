# frozen_string_literal: true

module Yuzakan
  module Actions
    module About
      class Index < Yuzakan::Action
        security_level 0
        required_configuration false
        required_authentication false

        def handle(req, res)
        end
      end
    end
  end
end
