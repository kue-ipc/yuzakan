module Api
  module Controllers
    module Groups
      class Update
        include Api::Action
        include SetGroup

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
