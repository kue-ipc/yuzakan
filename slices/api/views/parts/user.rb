# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class User < API::Views::Part
        # value is a DB::Sturct

        def to_h(restrict: false)
          hash = value.to_h
          if restrict
            hash.slice(:name, :label, :email)
          else
            hash.except(:id, :created_at, :updated_at, :affiliation_id, :group_id, :members)
              .merge({
                affiliation: hash.dig(:affiliation, :name),
                group: hash.dig(:group, :name),
                groups: hash[:members].map { |member| member.dig(:group, :name) },
              })
          end
        end

        def to_json(*, restrict: false, **) = helpers.params_to_json(to_h(restrict:), *, **)
      end
    end
  end
end
