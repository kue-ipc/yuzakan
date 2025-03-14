# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class Operation < Dry::Operation
    include Deps[
      "logger",
      "i18n.t",
      "i18n.l",
    ]

    # logging
    private def on_failure(failure)
      case failure
      in [:failure, message]
        logger.info "failure", operation: self.class.name, message:
      in [:invalid, validation]
        logger.warn "invalid", operation: self.class.name, validation:
      in [:error, e]
        logger.error e, operation: self.class.name
      in [type, message]
        logger.warn type, operation: self.class.name, message:
      else
        logger.error "unknwon failure", operation: self.class.name, failure:
      end
    end

    # common flows

    private def validate_name(name, max_size: 255)
      case name
      when Yuzakan::Patterns[:name]
        if max_size&.<(name.size)
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
