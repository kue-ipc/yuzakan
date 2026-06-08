# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Group < API::Views::StructPart
        # value is a DB::Struct

        def to_h(restricted: false)
          if restricted
            super().slice(:name, :label)
          else
            super().except(:affiliation_id).merge({affiliation: value.affiliation.name})
          end
        end
      end
    end
  end
end
