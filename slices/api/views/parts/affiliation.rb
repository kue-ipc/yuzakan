# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Affiliation < API::Views::Part
        def to_h(simple: false)
          value.to_h.slice(:name, :label, :note)
        end

        def to_json(simple: false) = helpers.params_to_json(to_h(simple:))
      end
    end
  end
end
