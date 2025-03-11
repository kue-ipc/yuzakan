# frozen_string_literal: true

require_relative "set_attr"

module API
  module Actions
    module Attrs
      class Show < API::Action
        include SetAttr

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = generate_json(@attr, assoc: current_level >= 2)
        end
      end
    end
  end
end
