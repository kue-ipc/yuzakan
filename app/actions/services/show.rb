# frozen_string_literal: true

module Yuzakan
  module Actions
    module Services
      class Show < Yuzakan::Action
        contract do
          params do
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
          end

          rule(:id).validate(:name)
        end

        def handle(request, response)
        end
      end
    end
  end
end
