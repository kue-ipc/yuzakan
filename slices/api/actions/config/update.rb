# frozen_string_literal: true

module API
  module Actions
    module Config
      class Update < API::Action
        def handle(request, response)
        end

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            optional(:config).schema(UpdateConfigValidator)
          end
        end

        params Params

        expose :config

        def initialize(config_repository: ConfigRepository.new,
          **opts)
          super
          @config_repository ||= config_repository
        end

        def handle(_request, _response)
          flash[:errors] ||= []

          @config = params[:config] || current_config

          unless params.valid?
            flash[:errors] << params.errors
            flash[:error] = "設定に失敗しました。"
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          @config_repository.current_update(@config)

          flash[:success] = "設定を更新しました。"
          redirect_to routes.path(:edit_config)
        rescue => e
          logger.error e
          flash[:errors] << e.message
          flash[:error] = "エラーが発生しました。"
          self.body = Admin::Views::Config::Edit.render(exposures)
        end
      end
    end
  end
end
