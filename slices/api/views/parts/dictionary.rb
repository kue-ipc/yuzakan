# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Dictionary < API::Views::Part
        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            terms = hash[:terms].map do |term|
              term.except(:id, :created_at, :updated_at, :dictionary_id)
            end
            {
              **hash.except(:id, :created_at, :updated_at, :terms),
              terms:,
            }
          end
        end

        def to_json(simple: false) = helpers.params_to_json(to_h(simple:))
      end
    end
  end
end
