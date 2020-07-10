# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      module Lock
        class Destroy
          include Web::Action

          expose :user
          expose :password

          def call(_params)
            gsuite_repository = ProviderRepository.new.first_gsuite_with_params

            @password = SecureRandom.alphanumeric(16)
            @user = gsuite_repository.adapter.unlock(
              current_user.name,
              @password)

            unless @user
              flash[:failure] = 'ロック解除に失敗しました。'
              redirect_to routes.path(:gsuite)
            end

            flash[:success] = 'Google アカウント のロックを解除し、パスワードをリセットしました。'
          end
        end
      end
    end
  end
end
