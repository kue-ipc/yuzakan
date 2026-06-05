# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class User < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restrict: false)
          if restrict
            super().slice(:name, :label, :email)
          else
            super().except(:affiliation_id, :group_id, :members)
              .merge({
                affiliation: value.affiliation&.name,
                group: value.group&.name,
                groups: value.members.map { |member| member.group.name },
              })
          end
        end
      end
    end
  end
end
