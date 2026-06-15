# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Attr < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false, simplified: false)
          case [restricted, simplified]
          in [_, true]
            super.slice(:name, :label)
          in [true, _]
            super.slice(:name, :label, :category, :type)
          in [false, false]
            mappings = value.mappings&.map do |mapping|
              {
                service: mapping.service.name,
                key: mapping.key,
                type: mapping.type,
                params: mapping.params,
              }
            end
            {**super, mappings:}
          end
        end
      end
    end
  end
end
