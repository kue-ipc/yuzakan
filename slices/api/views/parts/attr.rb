# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Attr < API::Views::Part
        # value is a DB::Sturct

        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            mappings = hash[:mappings].map do |mapping|
              mapping.except(:id, :created_at, :updated_at, :attr_id, :service_id)
                .merge({service: mapping.dig(:service, :name)})
            end
            hash.except(:id, :created_at, :updated_at).merge({mappings:})
          end
        end

        def to_json(*, simple: false, **) = helpers.params_to_json(to_h(simple:), *, **)
      end
    end
  end
end
