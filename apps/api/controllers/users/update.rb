require_relative './set_user'

module Api
  module Controllers
    module Users
      class Update
        include Api::Action
        include SetUser

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            required(:username).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:email).maybe(:str?, :email?, max_size?: 255)
            optional(:primary_group).maybe(:str?, :name?, max_size?: 255)
            optional(:groups) { array? { each { str? & name? & max_size?(255) } } }
            optional(:attrs) { hash? }
            optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
            optional(:clearance_level).filled(:int?)
            optional(:reserved).filled(:bool?)
            optional(:note).maybe(:str?, max_size?: 4096)
          end
        end

        params Params

        def call(params)
          halt_json 422, errors: {username: 'ユーザー名は変更できません。'} if @user.username != params[:username]

          current_providers = @providers.compact.keys
          if params[:providers]
            add_providers = params[:providers] - current_providers
            del_providers = current_providers - params[:providers]
            mod_providers = params[:providers] & current_providers
          else
            add_providers = []
            del_providers = []
            mod_providers = current_providers
          end

          if add_providers.size.positve?
            create_user({
              **params.slice(*USER_BASE_INFO, *USER_PROVIDER_INFO),
              providers: add_providers,
            })
          end

          if mod_providers.size.positve?
            update_user({
              **params.slice(*USER_BASE_INFO, *USER_PROVIDER_INFO),
              providers: mod_providers,
            })
          end

          delete_user({username: @user.username, providers: del_providers}) if del_providers.size.positive?

          set_sync_user

          if USER_REPOSITORY_INFO.any? { |name| params.key?(name) }
            @user = @user_repository.update(@user.id, params.slice(*USER_REPOSITORY_INFO))
          end

          self.body = user_json
        end
      end
    end
  end
end
