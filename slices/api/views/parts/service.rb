# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Service < API::Views::Part
        # value is a DB::Sturct

        def to_h(restrict: false)
          hash = value.to_h
          if restrict
            hash.slice(:name, :label)
          else
            hash.except(:id, :created_at, :updated_at)
          end
        end

        def to_json(*, restrict: false, **) = helpers.params_to_json(to_h(restrict:), *, **)
      end
    end
  end
end
