module Legacy
  module Controllers
    module Home
      class Index
        include Legacy::Action

        def call(params)
          redirect_to routes.path(:dashboard) if authenticated?
        end

        def authenticate!; end
      end
    end
  end
end
