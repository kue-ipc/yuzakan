require_relative './set_user'

module Api
  module Controllers
    module Users
      class Destroy
        include Api::Action
        include SetUser

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:erase).maybe(:bool?)
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
          unless @user.deleted?
            delete_user = DeleteUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
            result = delete_user.call({username: @username})
            halt_json 500, errors: result.errors if result.failure?
          end

          if params[:erase]
            erase_user = EraceUser.new(user_repository: @user_repository)
            result = erase_user.call({usarname: @username})
            halt_json 500, errors: result.errors if result.failure?
          end

          sync_user!

          self.body = user_json
        end
      end
    end
  end
end
