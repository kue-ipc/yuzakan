# frozen_string_literal: true

require 'hanami/action/cache'

module Web
  module Controllers
    module Gsuite
      module Password
        class Create
          include Web::Action

          include Hanami::Action::Cache

          cache_control :no_store

          expose :user
          expose :password

          def call(params)
            provider = ProviderRepository.new.first_gsuite_with_params

            result = ResetPassword.new(user: current_user,
                                       client: remote_ip,
                                       config: current_config,
                                       providers: [provider])
              .call(params.get(:gsuite_password_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'Google アカウントのパスワードリセットに失敗しました。'
              redirect_to routes.path(:gsuite)
            end

            @user = result.user_datas[provider.name]
            @password = result.password

            flash[:success] = 'Google アカウントのパスワードをリセットしました。'
          end
        end
      end
    end
  end
end
