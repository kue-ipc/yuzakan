# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Auth < API::Views::Part
        def to_h
          value.slice(:username)
        end

        def to_json(...) = to_h.to_json(...)
      end
    end
  end
end
