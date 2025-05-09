# frozen_string_literal: true

require "dry/types"

module Yuzakan
  Types = Dry.Types

  module Types
    NameString =
      Types::String.constrained(format: Yuzakan::Patterns[:name].ruby)
    PasswordString =
      Types::String.constrained(format: Yuzakan::Patterns[:password].ruby)
    HostString =
      Types::String.constrained(format: Yuzakan::Patterns[:host].ruby)
    DomainString =
      Types::String.constrained(format: Yuzakan::Patterns[:domain].ruby)
    EmailString =
      Types::String.constrained(format: Yuzakan::Patterns[:email].ruby)
  end
end
