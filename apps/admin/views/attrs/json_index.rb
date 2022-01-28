require_relative './index'

module Admin
  module Views
    module Attrs
      class JsonIndex < Index
        format :json

        def render
          raw JSON.generate(attrs)
        end
      end
    end
  end
end
