# frozen_string_literal: true

require_relative '../set_user'

module Api
  module Controllers
    module Users
      module Lock
        class Create
          include Api::Action
          include SetUser

          security_level 3

          def call(params) # rubocop:disable Lint/UnusedMethodArgument
            provider_lock_user({username: @name})

            load_user
            self.status = 201
            headers['Content-Location'] = routes.user_path(@user.name)
            self.body = user_json
          end
        end
      end
    end
  end
end
