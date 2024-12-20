# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class Operation < Dry::Operation
    private def validate_name(name)
      return Failure(:not_string) unless name.is_a?(String)
      return Failure(:invaild_name) unless name =~ Yuzakan::Patterns[:name].ruby

      Success(name)
    end
  end
end
