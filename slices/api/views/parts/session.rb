# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Session < API::Views::Part
        def to_json
          JSON.generate({
            uuid: value[:uuid],
            user: value[:user],
            created_at: value[:created_at],
            updated_at: value[:updated_at],
          })
        end
      end
    end
  end
end
