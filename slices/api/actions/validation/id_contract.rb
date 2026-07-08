# frozen_string_literal: true

module API
  module Actions
    module Validation
      class IdContract < Yuzakan::Validation::ActionContract
        params do
          required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
        end

        rule(:id).validate(:name)
      end
    end
  end
end
