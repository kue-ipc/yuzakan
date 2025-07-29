# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Affiliation < API::Views::Part
        # value is a DB::Sturct

        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            hash.except(:id, :created_at, :updated_at)
          end
        end

        def to_json(*, simple: false, **) = helpers.params_to_json(to_h(simple:), *, **)
      end
    end
  end
end
