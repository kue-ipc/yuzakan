# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class User < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false, simplified: false)
          case [restricted, simplified]
          in [true, _] | [_, true]
            super.slice(:name, :label)
          in [false, false]
            {
              **super.except(:affiliation_id, :group_id, :group, :members, :member_groups, :managings),
              affiliation: value.affiliation&.name,
              primary_group: value.group&.name,
              groups: value.member_groups&.map(&:name),
              services: value.services&.map(&:name),
            }
          end
        end
      end
    end
  end
end
