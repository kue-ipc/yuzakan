module Web
  module Controllers
    module Home
      class Index
        include Web::Action
        accept :html

        def call(_params)
          redirect_to routes.path(:dashboard) if authenticated?
        end

        def authenticate!
        end
      end
    end
  end
end
