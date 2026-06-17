# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Error < API::Views::Part
        def to_h
          hash = value.slice(:message, :invalid)
          if value.key?(:exception)
            hash[:exception] =
              if Hanami.env?(:development)
                value[:exception].full_message(highlight: false)
              else
                "#{value[:exception].class.name}: #{value[:exception].message}"
              end
          end
          hash
        end
      end
    end
  end
end
