# frozen_string_literal: true

require "hanami/action/cache"

module User
  module Actions
    module Providers
      module Lock
        class Destroy < User::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :user
          expose :password

          def handle(_request, _response)
            provider = ProviderRepository.new.first_google_with_adapter

            result = UnlockUser.new(
              user: current_user,
              client: client,
              config: current_config,
              providers: [provider]).call(params.get(:google_lock_destroy))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "Google アカウントのロック解除に失敗しました。"
              redirect_to routes.path(:google)
            end

            @user = result.user_datas[provider.name]
            @password = result.password

            flash[:success] = if @password
                                "Google アカウントのロックを解除し、パスワードをリセットしました。"
                              else
                                "Google アカウントのロックを解除しました。"
                              end
          end
        end
      end
    end
  end
end
