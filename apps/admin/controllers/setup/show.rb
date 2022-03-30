module Admin
  module Controllers
    module Setup
      class Show
        include Admin::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = Admin::Views::Setup::New.render(exposures) unless configurated?
        end

        def configurate!
        end
      end
    end
  end
end
