# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Affiliation < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false, simplified: false)
          case [restricted, simplified]
          in [true, _] | [_, true]
            super.slice(:name, :label)
          in [false, false]
            super
          end
        end
      end
    end
  end
end
