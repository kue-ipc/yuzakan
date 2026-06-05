# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Status < API::Views::Part
        def to_h
          {
            code: code,
            message: message,
          }
        end

        def code = value.to_i
        def message = Hanami::Http::Status.message_for(value.to_i)
      end
    end
  end
end
