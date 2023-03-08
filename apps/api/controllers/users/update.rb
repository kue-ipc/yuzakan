# frozen_string_literal: true

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
            optional(:name).filled(:str?, :name?, max_size?: 255)
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

        def call(params)
          if params[:name] && @user.name != params[:name]
            halt_json 422, errors: {
              name: I18n.t('errors.unchangeable', name: I18n.t('attributes.user.name')),
            }
          end

          @user_repository.update(@user.id, params.to_h.except(:id))

          if params[:providers]&.size&.positive?
            current_providers = @providers.compact.keys

            add_providers = params[:providers] - current_providers
            mod_providers = params[:providers] & current_providers
            del_providers = current_providers - params[:providers]

            unless add_providers.empty?
              provider_create_user({
                **params.to_h,
                username: @name,
                providers: add_providers,
              })
            end

            unless mod_providers.empty?
              provider_update_user({
                **params.to_h,
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
          end

          load_user

          self.body = user_json
        end
      end
    end
  end
end
