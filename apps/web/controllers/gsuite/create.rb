require 'hanami/action/cache'

module Web
  module Controllers
    module Gsuite
      class Create
        include Web::Action
        include Hanami::Action::Cache

        cache_control :no_store

        params do
          required(:agreement) { filled? & bool? }
        end

        expose :user
        expose :password

        def call(params)
          unless params.get(:agreement)
            flash[:failure] = '同意がありません。'
            redirect_to routes.path(:gsuite)
          end

          provider = ProviderRepository.new.first_gsuite_with_params

          result = CreateUser.new(user: current_user, client: remote_ip,
                                  config: current_config,
                                  providers: [provider])
            .call(params.get(:gsuite_create))

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
