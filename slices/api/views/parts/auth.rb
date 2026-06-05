# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Auth < API::Views::Part
        def to_h = super.slice(:username)
      end
    end
  end
end
