module Api
  module Controllers
    module Adapters
      class Index
        include Api::Action

        def call(params)
          adapters = ADAPTERS_MANAGER.hash.map do |key, value|
            {
              name: key,
              label: value.label,
            }
          end
          self.body = JSON.generate(adapters)
        end
      end
    end
  end
end
