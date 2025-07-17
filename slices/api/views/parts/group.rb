# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Group < API::Views::Part
        def to_h(simple: false)
          hash = value.to_h
          if simple
            hash.slice(:name, :label)
          else
            {
              **hash.except(:id, :created_at, :updated_at, :affiliation_id),
              affiliation: hash.dig(:affiliation, :name),
            }
          end
        end

        def to_json(simple: false) = helpers.params_to_json(to_h(simple:))
      end
    end
  end
end
