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
            required(:name).filled(:str?, :name?, max_size?: 255)
            optional(:password).maybe(:str?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:email).maybe(:str?, :email?, max_size?: 255)

            optional(:note).maybe(:str?, max_size?: 4096)
            optional(:clearance_level).filled(:int?)
            optional(:prohibited).filled(:bool?)
            optional(:deleted).filled(:bool?)
            optional(:deleted_at).filled(:date_time?)

            optional(:primary_group).maybe(:str?, :name?, max_size?: 255)
            optional(:groups).each(:str?, :name?, max_size?: 255)

            optional(:attrs) { hash? }

            optional(:providers).each(:str?, :name?, max_size?: 255)
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

          @name = params[:name]
          load_user
          halt_json 422, errors: {name: [I18n.t('errors.uniq?')]} if @user

          password = params[:password] || generate_password.password

          if params[:deleted]
            # どのプロバイダーにも登録しない削除済みユーザーの作成する。
            # プロバイダーの指定は無視する。
            # 削除日時が指定されていない場合は現在の日時を削除日時とする。
            @user = @user_repository.create({deleted: Time.now, **params.to_h})
          elsif params[:providers]&.size&.positive?
            provider_create_user({
              **params.to_h,
              username: @name,
              password: password,
            })
            load_user
            @user_repository.update(@user.id, {**params.to_h, deleted: false, deleted_at: nil})
          else
            halt_json 422, errors: {providers: [I18n.t('errors.min_size?', num: 1)]}
          end

          load_user

          self.status = 201
          headers['Content-Location'] = routes.user_path(@user.name)
          self.body = user_json(password: password)
        end
      end
    end
  end
end
