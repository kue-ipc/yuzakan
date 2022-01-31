module Web
  module Controllers
    module Uninitialized
      class Index
        include Web::Action

        security_level 0

        def call(params)
        end

        def configurate!
          redirect_to routes.path(:root) if configurated?
        end
      end
    end
  end
end
