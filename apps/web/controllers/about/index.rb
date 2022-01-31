module Web
  module Controllers
    module About
      class Index
        include Web::Action

        accept :html
        security_level 0

        def call(_params)
        end
      end
    end
  end
end
