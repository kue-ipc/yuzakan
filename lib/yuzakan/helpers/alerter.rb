# frozen_string_literal: true

module Yuzakan
  module Helpers
    module Alerter
      # Bootstrapでの色
      private def level_colors
        {
          success: 'success',
          failure: 'warning',
          fatal: 'danger',
          error: 'danger',
          warn: 'warning',
          info: 'info',
          debug: 'secondary',
          unknown: 'primary',
        }
      end

      private def msg_errors
        return @msg_errors if @msg_errors

        flash_errors!
        @msg_errors
      end

      private def param_errors
        return @param_errors if @param_errors

        flash_errors!
        @param_errors
      end

      private def flash_errors!
        @msg_errors, @param_errors = devide_errors(flash[:errors])
      end

      private def devide_errors(errors)
        return [[], {}] if errors.nil?

        array_errors = []
        hash_errors = Hash.new {[]}

        errors.each do |error|
          case error
          when String
            array_errors << error
          when Hash
            error.each do |key, value|
              hash_errors[key] += value
            end
          end
        end
        [array_errors, hash_errors]
      end
    end
  end
end
