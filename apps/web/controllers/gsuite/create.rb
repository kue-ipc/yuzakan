# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      class Create
        include Web::Action

        params do
          required(:agreement) { filled? & bool? }
        end

        expose :user
        expose :password

        def call(params)
          if params.get(:agreement) != '1'
            flash[:failure] = '同意がありません。'
            redirect_to routes.path(:gsuite)
          end

          provider = ProviderRepository.new.first_gsuite_with_params

          result = CreateUser.new(user: current_user, client: remote_ip,
                                  config: current_config,
                                  providers: [provider]).call

          if result.failure?
            flash[:errors] = result.errors
            flash[:failure] = 'Google アカウント の作成に失敗しました。'
            redirect_to routes.path(:gsuite)
          end

          @user = result.user_datas[provider.name]
          @password = result.password

          flash[:success] = 'Google アカウント を作成しました。'
        end
      end
    end
  end
end
