# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class Operation < Dry::Operation
    include Deps["logger"]

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
          Failure[:invalid, {name: [t("errors.max_size?", num: max_size)]}]
        else
          Success(name)
        end
      when String
        Failure[:invalid, {name: [t("errors.format?")]}]
      when Symbol
        validate_name(name.to_s)
      when nil
        Failure[:invalid, {name: [t("errors.filled?")]}]
      else
        Failure[:invalid, {name: [t("errors.str?")]}]
      end
    end

    private def validate_password(password)
      case password
      when "", nil
        Failure([:invalid, {password: [:filled?]}])
      when String
        Success(password)
      else
        Failure([:invalid, {password: [:str?]}])
      end
    end
  end
end
