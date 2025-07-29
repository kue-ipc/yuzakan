# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Session < API::Views::Part
        def to_h
          {
            uuid: value[:uuid],
            user: value[:user],
            trusted: value[:trusted],
            expires_at: value[:expires_at] && Time.at(value[:expires_at]),
          }
        end

        def to_json(...) = helpers.params_to_json(to_h)
      end
    end
  end
end
