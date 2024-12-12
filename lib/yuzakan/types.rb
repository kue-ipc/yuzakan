# frozen_string_literal: true

require "dry/types"

module Yuzakan
  Types = Dry.Types

  module Types
    # Define your custom types here
    NameString = Types::String.constrained(
      format: /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/)

    NameOrStarString = Types::String.constrained(
      format: /\A(?:[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*|\*)\z/)

    # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
    EmailString = Types::String.constrained(
      format: %r{\A
        [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+
        @
        [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
      \z}x)

    DomainString = Types::String.constrained(
      format: /\A[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
      )

    PasswordString = Types::String.constrained(
      format: /\A[\x20-\x7e]*\Z/)
  end
end
