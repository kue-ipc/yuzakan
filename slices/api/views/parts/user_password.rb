# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class UserPassword < API::Views::Part
        def to_h = value.to_h
        def to_json(...) = helpers.params_to_json(to_h, ...)
      end
    end
  end
end
