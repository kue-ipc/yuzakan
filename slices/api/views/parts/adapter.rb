# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Adapter < API::Views::Part
        def to_h
          {
            name: value.adatper_name,
            label: value.display_name,
            group: value.has_group?,
            primary: value.has_primary_group?,
            params: value.params,
          }
        end

        def to_json(...) = helpers.params_to_json(to_h)

        def params
          value.content
        end
      end
    end
  end
end
