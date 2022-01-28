module Web
  module Controllers
    module About
      class Browser
        include Web::Action
        accept :html

        def call(params)
        end

        def configurate!
        end

        def authenticate!
        end
      end
    end
  end
end
