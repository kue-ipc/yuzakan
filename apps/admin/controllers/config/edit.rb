# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Config
      class Edit
        include Admin::Action

        expose :config

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @config = current_config
        end
      end
    end
  end
end
