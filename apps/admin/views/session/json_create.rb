require_relative 'create'

module Admin
  module Views
    module Session
      class JsonCreate < Create
        format :json

        def render
          raw JSON.generate(data)
        end
      end
    end
  end
end
