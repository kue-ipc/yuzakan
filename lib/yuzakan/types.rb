# frozen_string_literal: true

require "dry/types"

module Yuzakan
  Types = Dry.Types

  module Types
    NameString = Types::String.constrained(format: Patterns::NAME.ruby)
    PasswordString = Types::String.constrained(format: Patterns::PASSSWORD.ruby)

    HostString = Types::String.constrained(format: Patterns::HOST.ruby)
    DomainString = Types::String.constrained(format: Patterns::DOMAI.ruby)
    EmailString = Types::String.constrained(format: Patterns::EMAIL.ruby)
  end
end
