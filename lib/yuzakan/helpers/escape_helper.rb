require_relative '../utils/refine_escape'

module Yuzakan
  module Helpers
    module EscapeHelper
      using Utils::RefineEscape

      private def escape_json(input)
        Hanami::Utils::Escape.json(input)
      end
      alias hj escape_json
      private :hj
    end
  end
end
