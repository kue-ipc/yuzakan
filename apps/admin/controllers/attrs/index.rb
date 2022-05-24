module Admin
  module Controllers
    module Attrs
      class Index
        include Admin::Action

        security_level 5

        def call(params)
        end
      end
    end
  end
end
