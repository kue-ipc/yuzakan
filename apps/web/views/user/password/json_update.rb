# frozen_string_literal: true

require_relative 'update'

module Web
  module Views
    module User
      module Password
        class JsonUpdate < Update
          format :json

          def render
            raw JSON.generate(data)
          end
        end
      end
    end
  end
end
