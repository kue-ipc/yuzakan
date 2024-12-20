# frozen_string_literal: true

require "dry/types"

module Yuzakan
  Types = Dry.Types

  module Types
    NameString =
      Types::String.constrained(format: Yuzakan::Patterns[:name].ruby)
    PasswordString =
      Types::String.constrained(format: Yuzakan::Patterns[:password].ruby)
    EmailString =
      Types::String.constrained(format: Yuzakan::Patterns[:email].ruby)
  end
end
