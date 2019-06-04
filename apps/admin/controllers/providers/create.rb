module Admin
  module Controllers
    module Providers
      class Create
        include Admin::Action

        def call(params)
          pp params
        end
      end
    end
  end
end
