# frozen_string_literal: true

module API
  module Actions
    module Adapters
      class Index < API::Action
        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          adapters = ADAPTERS_MANAGER.hash.map do |key, value|
            {name: key, label: value.label}
          end.sort_by { |adapter| adapter[:name] }
          self.body = generate_json(adapters)
        end
      end
    end
  end
end
