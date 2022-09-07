module Api
  module Controllers
    module Users
      module SetUser
        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        def self.included(action)
          action.class_eval do
            params Params
            before :set_user
          end
        end

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        private def set_user
          unless params.valid?
            if params.errors.key?(:id)
              halt_json 400, errors: [params.errors]
            else
              halt_json 422, errors: [params.errors]
            end
          end

          username = params[:id]

          sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = sync_user.call({username: username})
          halt_json 500, erros: result.errors if result.failure?
          @user = result.user
          @userdata = result.userdata
          @providers = result.providers

          halt_json 404 if @user.nil?
        end

        private def user_json
          generate_json({
            **convert_for_json(@user),
            userdata: @userdata,
            provider_userdatas: @providers.compact.map { |k, v| {provider: {name: k}, userdata: v} },
          })
        end
      end
    end
  end
end
