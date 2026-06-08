# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Service < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false)
          if restricted
            super().slice(:name, :label)
          else
            super()
          end
        end
      end
    end
  end
end
