module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action

        def call(params)
        end

        def authenticate!; end
      end
    end
  end
end
