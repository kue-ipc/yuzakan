module Web
  module Controllers
    module Home
      class Index
        include Web::Action

        accept :html
        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = Web::Views::Home::Login.render(exposures) unless authenticated?
        end
      end
    end
  end
end
