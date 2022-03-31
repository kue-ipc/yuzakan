module Api
  module Controllers
    module Users
      module Lock
        class Create
          include Api::Action

          def call(params)
            self.body = 'OK'
          end
        end
      end
    end
  end
end
