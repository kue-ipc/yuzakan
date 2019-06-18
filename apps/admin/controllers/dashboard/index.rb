module Admin
  module Controllers
    module Dashboard
      class Index
        include Admin::Action

        def call(params)
          pp current_user
        end
      end
    end
  end
end
