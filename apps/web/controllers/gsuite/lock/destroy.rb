# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      module Lock
        class Destroy
          include Web::Action

          expose :user
          expose :password

          def call(params)
            provider = ProviderRepository.new.first_gsuite_with_params

            result = UnlockUser.new(
              user: current_user,
              client: remote_ip,
              config: current_config,
              providers: [provider]
            ).call(params.get(:gsuite_lock_destroy))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'Google アカウントのロック解除に失敗しました。'
              redirect_to routes.path(:gsuite)
            end
  
            @user = result.user_datas[provider.name]
            @password = result.password
  
            flash[:success] = 'Google アカウントのロックを解除し、パスワードをリセットしました。'
          end
        end
      end
    end
  end
end
