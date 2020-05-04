# frozen_string_literal: true

module Web
  module Helpers
    module Escaper
      using Yuzakan::Utils::RefineEscape

      private def escape_json(input)
        Hanami::Utils::Escape.json(input)
      end

      alias hj escape_json
      private :hj
    end
  end
end
