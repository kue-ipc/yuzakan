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
          sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = sync_user.call({username: current_user.name})
          halt_json 500, erros: result.errors if result.failure?

          halt_json 404 unless result.user

          self.body = generate_json({
            **convert_for_json(result.user),
            userdata: result.userdata,
            userdata_list: result.userdata_list,
          })
        end
      end
    end
  end
end
