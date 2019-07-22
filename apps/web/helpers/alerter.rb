# frozen_string_literal: true

module Web
  module Helpers
    module Alerter

      private

      def param_errors
        return @param_errors if @param_errors

        @param_errors = Hash.new { [] }
        flash[:errors]&.each do |msg|
          if msg.is_a?(Hash)
            msg.each do |key, value|
              @param_errors[key.intern] += [value].flatten
            end
          end
        end
        @param_errors
      end

      def param_successes
        return @param_successes if @param_successes

        @param_successes = Hash.new { [] }
        flash[:successes]&.each do |msg|
          if msg.is_a?(Hash)
            msg.each do |key, value|
              @param_successes[key.intern] += [value].flatten
            end
          end
        end
        @param_successes
      end
    end
  end
end
