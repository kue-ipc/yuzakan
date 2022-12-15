require_relative './set_user'

module Api
  module Controllers
    module Users
      module SetUser
        include SyncUser

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

        # 下記のインスタンス変数を設定する。
        # - @username
        # - @user
        # - @userdata
        # - @providers
        private def set_user
          halt_json 400, errors: [params.errors] unless params.valid?

          @username = params[:id]
          syne_user!
          halt_json 404 if @user.nil?
        end
      end
    end
  end
end
