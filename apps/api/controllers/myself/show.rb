module Api
  module Controllers
    module Myself
      class Show
        include Api::Action

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          read_user = ReadUser.new(provider_repository: @provider_repository)
          result = read_user.call(username: current_user.name)

          halt_json 500, erros: result.errors if result.failure?

          self.body = generate_json({
            **convert_for_json(current_user),
            userdatas: result.userdatas,
          })
        end
      end
    end
  end
end
