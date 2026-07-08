# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Validation
          class UserServiceContract < Yuzakan::Validation::ActionContract
            params do
              required(:service_id).filled(:str?, max_size?: MAX_STRING_SIZE)
              required(:user_id).filled(:str?, max_size?: MAX_STRING_SIZE)
            end

            rule(:service_id).validate(:name)
            rule(:user_id).validate(:name)
          end
        end
      end
    end
  end
end
