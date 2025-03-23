# frozen_string_literal: true

require "hanami/action/cache"

module User
  module Actions
    module Providers
      class Create < User::Action
        include Hanami::Action::Cache

        cache_control :no_store

        params do
          required(:agreement) { filled? & bool? }
        end

        expose :user
        expose :password

        def handle(_req, _res)
          unless params.get(:agreement)
            flash[:failure] = "同意がありません。"
            redirect_to routes.path(:google)
          end

          provider = ProviderRepository.new.first_google_with_adapter

          result = ProviderCreateUser.new(user: current_user, client: client,
            config: current_config,
            providers: [provider])
            .call(params.get(:google_create))

          if result.failure?
            flash[:errors] = result.errors
            flash[:failure] = "Google アカウント の作成に失敗しました。"
            redirect_to routes.path(:google)
          end

          @user = result.user_datas[provider.name]
          @password = result.password

          flash[:success] = "Google アカウント を作成しました。"
        end
      end
    end
  end
end
