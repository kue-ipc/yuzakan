# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Status < API::Views::Part
        def code = value.to_i
        def message = Hanami::Http::Status.message_for(value)
      end
    end
  end
end
