# frozen_string_literal: true

module Admin
  module Actions
    module Groups
      class Show < Admin::Action
        contract Validation::IdContract

        def handle(_request, _response)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
