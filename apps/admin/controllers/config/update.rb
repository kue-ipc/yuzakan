# frozen_string_literal: true

require_relative '../../../../lib/yuzakan/validators/config_validator'
require_relative '../../../../lib/yuzakan/validators/provider_validator'
require_relative '../../../../lib/yuzakan/validators/attr_validator'

module Admin
  module Controllers
    module Config
      class Update
        include Admin::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            optional(:import).schema do
              optional(:yaml)
            end
            optional(:config).schema(ConfigValidator)
          end
        end

        class YamlValidator
          include Hanami::Validations

          predicates NamePredicates
          messages :i18n

          validations do
            optional(:config).schema(ConfigValidator)
            optional(:providers) { array? { each { schema(ProviderValidator) } } }
            optional(:attrs) { array? { each { schema(AttrValidator) } } }
          end
        end

        params Params

        expose :config

        def initialize(config_repository: ConfigRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
        end

        def call(params)
          flash[:errors] ||= []

          @config = params[:config] || current_config

          unless params.valid?
            flash[:errors] << params.errors
            flash[:error] = '設定に失敗しました。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          @config_repository.current_update(@config)

          flash[:success] = '設定を更新しました。'
          redirect_to routes.path(:edit_config)
        rescue => e
          Hanami.logger.error e
          flash[:errors] << e.message
          flash[:error] = 'エラーが発生しました。'
          self.body = Admin::Views::Config::Edit.render(exposures)
        end
      end
    end
  end
end
