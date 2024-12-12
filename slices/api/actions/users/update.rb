# frozen_string_literal: true

require_relative "set_user"

module API
  module Actions
    module Users
      class Update < API::Action
        include SetUser

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:email).maybe(:str?, :email?, max_size?: 255)

            optional(:note).maybe(:str?, max_size?: 4096)
            optional(:clearance_level).filled(:int?)
            optional(:prohibited).filled(:bool?)
            optional(:deleted).filled(:bool?)
            optional(:deleted_at).maybe(:date_time?)

            optional(:primary_group).maybe(:str?, :name?, max_size?: 255)
            optional(:groups).each(:str?, :name?, max_size?: 255)

            optional(:attrs) { hash? }

            optional(:providers).each(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def handle(_request, _response)
          if params[:name] && @user.name != params[:name]
            halt_json 422, errors: {
              name: I18n.t("errors.unchangeable", name: I18n.t("attributes.user.name")),
            }
          end

          halt_json 422, errors: {attrs: I18n.t("errors.filled?")} if params[:providers] && params[:attrs].nil?

          params = params.to_h

          # ユーザー属性の変更
          @user_repository.update(@user.id, params.except(:id))

          # グループがない場合は@userのグループに設定
          params[:primary_group] ||= @user.primary_group&.name
          params[:groups] ||= @user.groups&.map(&:name) || []

          # グループと属性を各プロバイダーに反映
          if params[:providers]
            current_providers = @providers.compact.keys

            add_providers = params[:providers] - current_providers
            mod_providers = params[:providers] & current_providers
            del_providers = current_providers - params[:providers]

            unless add_providers.empty?
              provider_create_user({
                **params,
                username: @name,
                providers: add_providers,
              })
            end

            unless mod_providers.empty?
              provider_update_user({
                **params,
                username: @name,
                providers: mod_providers,
              })
            end

            unless del_providers.empty?
              provider_delete_user({
                username: @name,
                providers: del_providers,
              })
            end
          elsif !@providers.empty?
            provider_update_user({
              **params,
              username: @name,
              providers: @providers.keys,
            })
          end

          load_user

          self.body = user_json
        end
      end
    end
  end
end
