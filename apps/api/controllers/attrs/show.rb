# frozen_string_literal: true

require_relative './set_attr'

module Api
  module Controllers
    module Attrs
      class Show
        include Api::Action
        include SetAttr

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = generate_json(@attr, assoc: current_level >= 2)
        end
      end
    end
  end
end
