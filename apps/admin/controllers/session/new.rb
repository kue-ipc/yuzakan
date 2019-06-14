module Admin
  module Controllers
    module Session
      class New
        include Admin::Action

        def call(params)
        end

        def authenticate!; end
      end
    end
  end
end
