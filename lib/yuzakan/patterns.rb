# frozen_string_literal: true

# Regular expressions patterns comiptale with
# Ruby Regexp and ECMAScript RegExp with v flag

module Yuzakan
  module Patterns
    class Pattern
      attr_reader :pattern, :ruby, :ecma_script

      def initialize(pattern)
        @pattern = -pattern
        @ruby = /\A#{pattern}\z/
        @ecma_script = "/^#{pattern}$/v"
      end

      alias to_s pattern
    end

    MAP =
      {
        name: '[a-z0-9_](?:[0-9a-z_\-]|\.[0-9a-z_\-])*',
        password: '[\x20-\x7e]*',
      }.then do |hash|
        # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
        host = "[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        domain = "#{host}(?:\\.#{host})*"
        email = "[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~\\-]+@#{domain}"
        hash.merge({host:, domain:, email:})
      end.transform_valuse { |value| Pattern.new(value) }

    def self.[](key)
      MAP[key]
    end
  end
end
