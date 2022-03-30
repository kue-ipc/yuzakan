module Web
  module Controllers
    module About
      class Browser
        include Web::Action

        accept :html
        security_level 0

        def call(params)
        end

        def configurate!
        end
      end
    end
  end
end
