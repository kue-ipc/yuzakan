module Api
  module Controllers
    module Users
      module Lock
        class Destroy
          include Api::Action

          security_level 3

          def call(params)
            self.body = {}.to_json
          end
        end
      end
    end
  end
end
