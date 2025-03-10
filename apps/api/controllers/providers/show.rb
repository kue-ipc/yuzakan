# frozen_string_literal: true

require_relative "set_provider"

module Api
  module Controllers
    module Providers
      class Show
        include Api::Action
        include SetProvider

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = provider_json
        end
      end
    end
  end
end
