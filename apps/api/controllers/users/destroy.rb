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
          provider_delete_user({username: @username}) unless @user.deleted?

          load_user(sync: true)

          @user_repository.delete(@user.id) if params[:erase] && @user.deleted?

          self.body = user_json
        end
      end
    end
  end
end
