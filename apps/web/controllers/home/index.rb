module Web
  module Controllers
    module Home
      class Index
        include Web::Action

        accept :html
        security_level 0

        def call(_params)
          redirect_to routes.path(:dashboard) if authenticated?
        end
      end
    end
  end
end
