module Web
  module Controllers
    module About
      class Index
        include Web::Action

        accept :html
        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
        end
      end
    end
  end
end
