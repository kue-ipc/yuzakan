module Web
  module Controllers
    module Uninitialized
      class Index
        include Web::Action

        def call(params)
        end

        def configurate!
          redirect_to routes.path(:root) unless configurated?
        end

        def authenticate!
        end
      end
    end
  end
end
