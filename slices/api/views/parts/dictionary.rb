# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Dictionary < API::Views::Part
        # value is a DB::Sturct

        def to_h(restrict: false)
          hash = value.to_h
          if restrict
            hash.slice(:name, :label)
          else
            terms = hash[:terms].map do |term|
              term.except(:id, :created_at, :updated_at, :dictionary_id)
            end
            hash.except(:id, :created_at, :updated_at).merge({terms:})
          end
        end

        def to_json(*, restrict: false, **) = helpers.params_to_json(to_h(restrict:), *, **)
      end
    end
  end
end
