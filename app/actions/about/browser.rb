# frozen_string_literal: true

module Yuzakan
  module Actions
    module About
      class Browser < Yuzakan::Action
        accept :html
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
        end

        def configurate!
        end
      end
    end
  end
end
