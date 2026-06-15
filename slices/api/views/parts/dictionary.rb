# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Dictionary < API::Views::StructPart
        # value is a DB::Sturct

        def to_h(restricted: false, simplified: false)
          case [restricted, simplified]
          in [true, _] | [_, true]
            super.slice(:name, :label)
          in [false, false]
            terms = value.terms&.map { |term| term_to_h(term) }
            {**super, terms:}
          end
        end

        def term_to_h(term)
          {
            term: term.term,
            description: term.description,
          }
        end
      end
    end
  end
end
