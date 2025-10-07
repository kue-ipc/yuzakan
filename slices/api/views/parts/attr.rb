# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Attr < API::Views::Part
        # value is a DB::Sturct

        def to_h(restrict: false)
          hash = value.to_h
          if restrict
            hash.slice(:name, :label, :category, :type)
          else
            mappings = hash[:mappings].map do |mapping|
              mapping.except(:id, :created_at, :updated_at, :attr_id, :service_id)
                .merge({service: mapping.dig(:service, :name)})
            end
            hash.except(:id, :created_at, :updated_at).merge({mappings:})
          end
        end

        def to_json(*, restrict: false, **) = helpers.params_to_json(to_h(restrict:), *, **)
      end
    end
  end
end
