# frozen_string_literal: true

module API
  module Actions
    module Adapters
      class Index < API::Action
        include Deps["adapters"]

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          obj = adapters.map { |key, value| {name: key, label: value.label} }
            .sort_by { |adapter| adapter[:name] }
          self.body = generate_json(obj)
        end
      end
    end
  end
end
