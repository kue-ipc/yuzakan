# frozen_string_literal: true

module Web
  module Error
    private def devide_errors(errors)
      str_errors = []
      param_errors = {}

      errors.each do |msg|
        if msg.is_a?(Hash)
          msg.each do |key, value|
            param_errors[key.to_s] ||= []
            param_errors[key.to_s] += [value].flatten
          end
        else
          str_errors << msg
        end
      end
      pp param_errors
      [str_errors, param_errors]
    end
  end
end
