module Api
  module Controllers
    module Providers
      class Destroy
        include Api::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
