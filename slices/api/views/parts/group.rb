# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Group < API::Views::StructPart
        # value is a DB::Struct

        def to_h(restricted: false, simplified: false)
          case [restricted, simplified]
          in [true, _] | [_, true]
            super.slice(:name, :label)
          in [false, false]
            super
              .except(:affiliation_id, :affiliation,
                :users, :members, :member_users,
                :managings, :services)
              .merge({
                affiliation: value.affiliation&.name,
                services: value.managings&.map { |managing| mapping_to_h(managing) } ||
                  value.services&.map(&:name),
              })
          end
        end

        private def mapping_to_h(mapping)
          {
            name: mapping.service.name,
            unmanageable: mapping.unmanageable,
          }
        end
      end
    end
  end
end
