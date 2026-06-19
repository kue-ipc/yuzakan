# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Error < API::Views::Part
        def to_h
          {
            message: value[:message],
            invalid: value[:invalid]&.to_h,
            exception: value[:exception] && exception_to_string(value[:exception]),
          }.compact
        end

        def exception_to_string(exception)
          if Hanami.env?(:development)
            exception.full_message(highlight: false)
          else
            "#{exception.class.name}: #{exception.message}"
          end
        end
      end
    end
  end
end
