# frozen_string_literal: true

require "hanami/utils/escape"

module Yuzakan
  module Utils
    # @see https://github.com/hanami/utils
    # /lib/hanami/utils/escape.rb
    # @see https://github.com/hanami/helpers
    # /lib/hanami/helpers/escape_helper.rb
    # @see https://github.com/rails/rails
    # /activesupport/lib/active_support/core_ext/string/output_safety.rb
    module RefineEscape
      include Hanami::Utils::Escape

      def self.json_chars
        @json_chars ||= {
          "&" => '\u0026',
          ">" => '\u003e',
          "<" => '\u003c',
          "\u2028" => '\u2028',
          "\u2029" => '\u2029',
        }
      end

      refine Hanami::Utils::Escape.singleton_class do
        # Escape JSON contents
        #
        # modification of Hanami::Utils::Escape.html(input)
        # Copyright © 2014-2017 Luca Guidi
        # MIT License
        #
        def json(input)
          input = encode(input)
          return input if input.is_a?(SafeString)

          result = SafeString.new

          input.each_char do |chr|
            result << RefineEscape.json_chars.fetch(chr, chr)
          end

          result
        end
      end
    end
  end
end
