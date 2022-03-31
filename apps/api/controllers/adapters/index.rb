module Api
  module Controllers
    module Adapters
      class Index
        include Api::Action

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          adapters = ADAPTERS_MANAGER.hash.map do |key, value|
            {name: key, label: value.label}
          end
          self.body = generate_json(adapters)
        end
      end
    end
  end
end
