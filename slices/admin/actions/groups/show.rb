# frozen_string_literal: true

module Admin
  module Actions
    module Groups
      class Show < Admin::Action
        params do
          required(:id).filled(:name, max_size?: 255)
        end

        params Params

        def handle(_request, _response)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
