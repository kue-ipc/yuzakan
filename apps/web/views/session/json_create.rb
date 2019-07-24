# frozen_string_literal: true

require_relative 'create'

module Web
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
