# frozen_string_literal: true

# Regular expressions patterns comiptale with
# Ruby Regexp and ECMAScript RegExp with v flag

module Yuzakan
  module Patterns
    class Pattern
      attr_reader :pattern

      def initialize(pattern)
        @pattern = -pattern
      end

      def ruby
        Regexp.compile("\\A#{@pattern}\\z")
      end

      def es
        "/^#{@pattern}$/v"
      end
    end
    NAME = Pattern.new('[a-z0-9_](?:[0-9a-z_\-]|\.[0-9a-z_\-])*')
    PASSWORD = Pattern.new('[\x20-\x7e]*')

    # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
    HOST = Pattern.new("[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?")
    DOMAIN = Pattern.new("#{HOST.pettern}(?:\\.#{HOST.pattern})*")
    EMAIL = Pattern.new("[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~\\-]+@#{DOMAIN.pattern}")
  end
end
