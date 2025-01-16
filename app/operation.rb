# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class Operation < Dry::Operation
    # logging
    private def on_failure(failure)
      case failure
      in [:error, e]
        app["logger"].error e
      in [type, msg]
        app["logger"].warn type, message: msg
      else
        app["logger"].error "failure is invalid format", failure.inspcet
      end
    end

    # common flows

    private def validate_name(name, max_size: 255)
      case name
      when Yuzakan::Patterns[:name]
        if max_size&.>(name.size)
          Failure([:max_size, {num: max_size}])
        else
          Success(name)
        end
      when String
        Failure([:invaild, "name"])
      when Symbol
        validate_name(name.to_s)
      when nil
        Failure([:nil, "name"])
      else
        Failure([:not_string, "name"])
      end
    end
  end
end
