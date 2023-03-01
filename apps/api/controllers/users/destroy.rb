# frozen_string_literal: true

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
            optional(:permanent).maybe(:bool?)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
        end

        def call(params)
          unless @user.deleted?
            provider_delete_user({username: @name}) unless @user.deleted?
            sync_user({username: @name})
          end

          @user_repository.delete(@user.id) if params[:permanent]

          self.body = user_json
        end
      end
    end
  end
end
