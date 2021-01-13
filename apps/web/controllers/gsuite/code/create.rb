require 'hanami/action/cache'

module Web
  module Controllers
    module Gsuite
      module Code
        class Create
          include Web::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :codes

          def call(_params)
            provider = ProviderRepository.new.first_gsuite_with_params

            result = GenerateVerificationCode.new(
              user: current_user,
              client: remote_ip,
              config: current_config,
              providers: [provider]
            ).call(params.get(:gsuite_code_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'バックアップコードの生成に失敗しました。'
              redirect_to routes.path(:gsuite)
            end

            @codes = result.user_datas[provider.name]
            flash[:success] = 'バックアップコードを生成しました。'
          end
        end
      end
    end
  end
end
