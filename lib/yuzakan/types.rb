# frozen_string_literal: true

require "dry/types"

module Yuzakan
  Types = Dry.Types

  module Types
    NameString = Types::String.constrained(format: Patterns[:name].ruby)
    PasswordString = Types::String.constrained(format: Patterns[:password].ruby)
    EmailString = Types::String.constrained(format: Patterns[:email].ruby)
  end
end
