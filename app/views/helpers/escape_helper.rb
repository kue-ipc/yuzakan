# frozen_string_literal: true

require_relative "../utils/refine_escape"

module Yuzakan
  module Views
    module Helpers
      module EscapeHelper
        using Utils::RefineEscape

        def escape_json(input)
          Hanami::Utils::Escape.json(input)
        end
        alias hj escape_json
      end
    end
  end
end
