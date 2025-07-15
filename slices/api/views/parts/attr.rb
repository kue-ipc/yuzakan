# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Attr < API::Views::Part
        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            mappings = hash[:mappings].map do |mapping|
              {
                **mapping.slice(:key, :type, :params),
                service: mapping[:service][:name],
              }
            end
            {
              **hash.except(:id, :created_at, :updated_at, :mappings),
              mappings:,
            }
          end
        end

        def to_json(simple: false) = helpers.params_to_json(to_h(simple:))
      end
    end
  end
end
