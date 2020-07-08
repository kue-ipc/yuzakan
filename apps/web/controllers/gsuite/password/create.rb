# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      module Password
        class Create
          include Web::Action

          expose :user
          expose :password

          def call(_params)
            gsuite_repository = ProviderRepository.new.first_gsuite_with_params

            @password = SecureRandom.alphanumeric(16)
            @user = gsuite_repository.adapter.change_password(
              current_user.name,
              @password)

            unless @user
              flash[:failure] = 'パスワードリセットに失敗しました。'
              redirect_to routes.path(:gsuite)
            end

            flash[:success] = 'Google アカウントのパスワードをリセットしました。'
          end
        end
      end
    end
  end
end
