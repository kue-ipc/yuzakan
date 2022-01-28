module Web
  module Controllers
    module About
      class Index
        include Web::Action
        accept :html

        def call(_params)
        end

        def configurate!
        end

        def authenticate!
        end
      end
    end
  end
end
