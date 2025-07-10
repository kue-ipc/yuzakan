# frozen_string_literal: true

module API
  module Actions
    module Users
      class Update < API::Action
        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
          optional(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          optional(:email).maybe(:email, max_size?: 255)

          optional(:note).maybe(:str?, max_size?: 4096)
          optional(:clearance_level).filled(:int?)
          optional(:prohibited).filled(:bool?)
          optional(:deleted).filled(:bool?)
          optional(:deleted_at).maybe(:date_time?)

          optional(:primary_group).maybe(:name, max_size?: 255)
          optional(:groups).each(:name, max_size?: 255)

          optional(:attrs) { hash? }

          optional(:services).each(:name, max_size?: 255)
        end

        def handle(_request, _response)
          if params[:name] && @user.name != params[:name]
            halt_json 422, errors: {
              name: t("errors.unchangeable", name: t("attributes.user.name")),
            }
          end

          if params[:services] && params[:attrs].nil?
            halt_json 422,
              errors: {attrs: t("errors.filled?")}
          end

          params = params.to_h

          # ユーザー属性の変更
          @user_repository.update(@user.id, params.except(:id))

          # グループがない場合は@userのグループに設定
          params[:primary_group] ||= @user.primary_group&.name
          params[:groups] ||= @user.groups&.map(&:name) || []

          # グループと属性を各プロバイダーに反映
          if params[:services]
            current_services = @services.compact.keys

            add_services = params[:services] - current_services
            mod_services = params[:services] & current_services
            del_services = current_services - params[:services]

            unless add_services.empty?
              service_create_user({
                **params,
                username: @name,
                services: add_services,
              })
            end

            unless mod_services.empty?
              service_update_user({
                **params,
                username: @name,
                services: mod_services,
              })
            end

            unless del_services.empty?
              service_delete_user({
                username: @name,
                services: del_services,
              })
            end
          elsif !@services.empty?
            service_update_user({
              **params,
              username: @name,
              services: @services.keys,
            })
          end

          load_user

          self.body = user_json
        end
      end
    end
  end
end
