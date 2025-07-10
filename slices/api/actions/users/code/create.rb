# frozen_string_literal: true

require "hanami/action/cache"

module User
  module Actions
    module Services
      module Code
        class Create < User::Action
          expose :codes

          def handle(_request, _response)
            service = ServiceRepository.new.first_google_with_adapter

            result = GenerateVerificationCode.new(
              user: current_user,
              client: client,
              config: current_config,
              services: [service]).call(params.get(:google_code_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "バックアップコードの生成に失敗しました。"
              redirect_to routes.path(:google)
            end

            @codes = result.user_datas[service.name]
            flash[:success] = "バックアップコードを生成しました。"
          end
        end
      end
    end
  end
end
