# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Config < API::Views::StructPart
        # value is a DB::Sturct

        # no simplified
        def to_h(restricted: false)
          if restricted
            super.slice(:title, :description, :contact_name, :contact_email, :contact_phone)
          else
            super
          end
        end
      end
    end
  end
end
