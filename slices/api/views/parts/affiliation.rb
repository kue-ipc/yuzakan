# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Affiliation < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false)
          hash = value.to_h
          if restricted
            hash.slice(:name, :label)
          else
            hash.except(:id, :created_at, :updated_at)
          end
        end
      end
    end
  end
end
