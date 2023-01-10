# frozen_string_literal: true

module Api
  module Controllers
    module Users
      module Lock
        class Create
          include Api::Action

          security_level 3

          def call(_params)
            self.status = 201
            self.body = {}.to_json
          end
        end
      end
    end
  end
end
