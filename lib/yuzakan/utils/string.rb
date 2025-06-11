# frozen_string_literal: true

require "hanami/middleware/body_parser/json_parser"
require "hanami/utils/string"

module Yuzakan
  module Utils
    module String
      def self.json_key(input)
        str = Hanami::Utils::String.underscore(input)
        if input.to_s.start_with?(/[A-Z]/)
          "_#{str}"
        else
          str
        end
      end

      def self.params_key(input)
        str = Hanami::Utils::String.classify(input)
        if !str.empty? && input.to_s.start_with?("_")
          str
        else
          str[0].downcase + str[1..]
        end
      end
    end
  end
end
