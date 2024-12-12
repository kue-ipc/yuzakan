# frozen_string_literal: true

require "hanami/action/cache"

module Admin
  module Actions
    module Config
      class Edit < Admin::Action
        security_level 5

        expose :config

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          @config = current_config
        end
      end
    end
  end
end
