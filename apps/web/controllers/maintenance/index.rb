module Web
  module Controllers
    module Maintenance
      class Index
        include Web::Action

        security_level 0

        def call(params)
        end

        def configurate!
          redirect_to routes.path(:uninitialized) unless configurated?
          redirect_to routes.path(:root) unless maintenance?
        end
      end
    end
  end
end
