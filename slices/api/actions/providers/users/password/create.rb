# frozen_string_literal: true

require "hanami/action/cache"

module User
  module Actions
    module Providers
      module Password
        class Create < User::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :user
          expose :password

          def handle(_request, _response)
            provider = ProviderRepository.new.first_google_with_adapter

            result = ResetPassword.new(user: current_user,
              client: client,
              config: current_config,
              providers: [provider])
              .call(params.get(:google_password_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "Google アカウントのパスワードリセットに失敗しました。"
              redirect_to routes.path(:google)
            end

            @user = result.user_datas[provider.name]
            @password = result.password

            flash[:success] = "Google アカウントのパスワードをリセットしました。"
          end
        end
      end
    end
  end
end
