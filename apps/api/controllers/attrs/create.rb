module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
