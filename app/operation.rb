# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class Operation < Dry::Operation
    # common flows

    private def validate_name(name)
      case name
      when Yuzakan::Patterns[:name].ruby
        Success(name)
      when String
        Failure([:invaild_name])
      when Symbol
        validate_name(name.to_s)
      when nil
        Failure([:nil])
      else
        Failure([:not_string])
      end
    end
  end
end
