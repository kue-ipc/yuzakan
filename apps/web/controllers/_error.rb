# frozen_string_literal: true

module Web
  module Error
    private def devide_errors(errors)
      str_errors = []
      param_errors = {}

      errors.each do |msg|
        if msg.is_a?(Hash)
          msg.each do |key, value|
            param_errors[key.intern] ||= []
            param_errors[key.intern] += [value].flatten
          end
        else
          str_errors << msg
        end
      end

      [errors, param_errors]
    end
  end
end
