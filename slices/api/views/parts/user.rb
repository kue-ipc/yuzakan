# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class User < API::Views::Part
        # value is a DB::Sturct

        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            hash.except(:id, :created_at, :updated_at, :affiliation_id, :group_id, :members)
              .merge({
                affiliation: hash.dig(:affiliation, :name),
                group: hash.dig(:group, :name),
                groups: hash[:members].map { |member| member.dig(:group, :name) },
              })
          end
        end

        def to_json(*, simple: false, **) = helpers.params_to_json(to_h(simple:), *, **)
      end
    end
  end
end
