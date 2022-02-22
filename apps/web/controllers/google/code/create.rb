require 'hanami/action/cache'

module Web
  module Controllers
    module Google
      module Code
        class Create
          include Web::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :codes

          def call(params)
            provider = ProviderRepository.new.first_google_with_adapter

            result = GenerateVerificationCode.new(
              user: current_user,
              client: client,
              config: current_config,
              providers: [provider]).call(params.get(:google_code_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'バックアップコードの生成に失敗しました。'
              redirect_to routes.path(:google)
            end

            @codes = result.user_datas[provider.name]
            flash[:success] = 'バックアップコードを生成しました。'
          end
        end
      end
    end
  end
end
