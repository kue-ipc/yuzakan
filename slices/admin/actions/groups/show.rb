# frozen_string_literal: true

module Admin
  module Actions
    module Groups
      class Show < Admin::Action
        contract do
          params do
            required(:id).filled(:str?, max_size?: 255)
          end

          rule(:id).validate(:name)
        end

        params Params

        def handle(_request, _response)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
