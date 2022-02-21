module Api
  module Controllers
    module Providers
      class Show
        include Api::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
