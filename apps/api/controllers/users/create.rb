# frozen_string_literal: true

require_relative './entity_user'

module Api
  module Controllers
    module Users
      class Create
        include Api::Action
        include EntityUser

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:username).filled(:str?, :name?, max_size?: 255)
            optional(:password).maybe(:str?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:email).maybe(:str?, :email?, max_size?: 255)
            optional(:primary_group).maybe(:str?, :name?, max_size?: 255)
            optional(:attrs) { hash? }
            optional(:providers).each(:str?, :name?, max_size?: 255)
            optional(:clearance_level).filled(:int?)
            optional(:prohibited).filled(:bool?)
            optional(:note).maybe(:str?, max_size?: 4096)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          @username = params[:username]
          set_sync_user
          halt_json 422, errors: {username: [I18n.t('errors.uniq?')]} if @user

          password = params[:password] || generate_password.password

          create_user({
            password: password,
            **params.slice(*USER_BASE_INFO, *USER_PROVIDER_INFO, :providers),
          })

          set_sync_user

          if @user.nil?
            @user = @user_repository.create(params.slice(*USER_BASE_INFO, *USER_REPOSITORY_INFO))
          elsif USER_REPOSITORY_INFO.any? { |name| params.key?(name) }
            @user = @user_repository.update(@user.id, params.slice(*USER_REPOSITORY_INFO))
          end

          self.status = 201
          headers['Content-Location'] = routes.user_path(@user.username)
          self.body = user_json(password: password)
        end
      end
    end
  end
end
