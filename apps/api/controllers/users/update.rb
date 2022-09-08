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
            optional(:display_name).filled(:str?, max_size?: 255)
            optional(:email).filled(:str?, :email?, max_size?: 255)
            optional(:clearance_level).filled(:int?)
            optional(:primary_group).filled(:str?, :name?, max_size?: 255)
            optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
            optional(:attrs) { hash? }
          end
        end

        params Params

        def call(params)
          halt_json 422, errors: {username: 'ユーザー名は変更できません。'} if @user.username != params[:username]

          current_providers = @providers.compact.keys
          add_providers = params[:providers] - current_providers
          del_providers = current_providers - params[:providers]
          mod_providers = params[:providers] & current_providers

          create_user = CreateUser.new(user_repository: @user_repository,
                                       provider_repository: @provider_repository)
          result = create_user.call({**params, providers: add_providers})
          halt_json 500, erros: result.errors if result.failure?

          delete_user = DeleteUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = delete_user.call({username: @user.username, providers: del_providers})
          halt_json 500, erros: result.errors if result.failure?

          # update_user = UpdateUser.new(user_repository: @user_repository,
          #                              provider_repository: @provider_repository)
          # result = update_user.call({**params, providers: mod_providers})
          # halt_json 500, erros: result.errors if result.failure?

          set_user
          self.body = user_json
        end
      end
    end
  end
end
