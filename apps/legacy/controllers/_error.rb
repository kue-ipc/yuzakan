# frozen_string_literal: true

module Legacy
  module Error
    private def devide_errors(errors)
      msg_errors = []
      param_errors = {}

      errors.each do |msg|
        if msg.is_a?(Hash)
          msg.each do |key, value|
            param_errors[key.to_s] ||= []
            param_errors[key.to_s] += [value].flatten
          end
        else
          msg_errors << msg
        end
      end
      [msg_errors, param_errors]
    end
  end
end
