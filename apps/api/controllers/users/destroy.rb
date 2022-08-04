module Api
  module Controllers
    module Users
      class Destroy
        include Api::Action

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end


        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          username = params[:id]

          sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = sync_user.call({username: username})
          halt_json 500, erros: result.errors if result.failure?
          user = result.user

          halt_json 404 unless result.user

          delete_user = DeleteUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = delete_user.call({username: username, providers: user})

          self.body = 'OK'
        end
      end
    end
  end
end
