module Web
  module Controllers
    module About
      class Legacy
        include Web::Action

        def call(params)
        end

        def configurate!; end
        def authenticate!; end
      end
    end
  end
end