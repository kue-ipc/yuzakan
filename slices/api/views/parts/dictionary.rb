# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Dictionary < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false)
          if restricted
            super().slice(:name, :label)
          else
            super().merge({terms: value.terms.map { |term| term_to_h(term) }})
          end
        end

        def term_to_h(term)
          term.to_h.except(:id, :created_at, :updated_at, :dictionary_id)
        end
      end
    end
  end
end
