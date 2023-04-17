# frozen_string_literal: true

require_relative '../../../../lib/yuzakan/validators/update_config_validator'
require_relative '../../../../lib/yuzakan/validators/create_provider_validator'
require_relative '../../../../lib/yuzakan/validators/create_attr_validator'

module Admin
  module Controllers
    module Config
      class Replace
        include Admin::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:import).schema do
              required(:yaml).schema do
                required(:filename) { str? }
                required(:tempfile) { size?(1..(1 * 1024 * 1024)) }
              end
            end
          end
        end

        class YamlValidator
          include Hanami::Validations

          predicates NamePredicates
          messages :i18n

          validations do
            optional(:config).schema(UpdateConfigValidator)
            optional(:providers).each(schema: CreateProviderValidator)
            optional(:attrs).each(schema: CreateAttrValidator)
          end
        end

        params Params

        expose :config

        def initialize(config_repository: ConfigRepository.new,
                       network_repository: NetworkRepository.new,
                       provider_repository: ProviderRepository.new,
                       provider_param_repository: ProviderParamRepository.new,
                       attr_repository: AttrRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
          @network_repository ||= network_repository
          @provider_repository ||= provider_repository
          @provider_param_repository ||= provider_param_repository
          @attr_repository ||= attr_repository
        end

        def call(params)
          flash[:errors] ||= []

          @config = current_config

          unless params.valid?
            flash[:errors] << params.errors
            flash[:error] = 'ファイルが選択されていません。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          import_yaml(params[:import][:yaml])

          unless flash[:errors].empty?
            flash[:failure] = 'インポートに失敗しました。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          flash[:success] = 'インポートに成功しました。'
          redirect_to routes.path(:edit_config)
        rescue => e
          Hanami.logger.error e
          flash[:failure] = 'インポートに失敗しました。'
          flash[:errors] << e.message
          self.body = Admin::Views::Config::Edit.render(exposures)
        end

        def import_yaml(upload_file)
          data = yaml_load(upload_file[:tempfile].read, filename: upload_file[:filename])

          data = validate_data(data)

          update_all(data)
        end

        private def yaml_load(yaml, filename: nil)
          YAML.safe_load(yaml, permitted_classes: [Symbol, Time, Date],
                               filename: filename,
                               symbolize_names: true)
        end

        private def validate_data(data)
          validate_result = YamlValidator.new(data).validate
          if validate_result.failure?
            flash[:errors] << {file: validate_result.messages}
            raise 'インポートするファイルのパラメーターが不正です。'
          end
          validate_result.output
        end

        private def update_all(data)
          @config_repository.transaction do
            update_config(data[:config]) if data[:config]

            update_providers(data[:providers])

            update_attrs(data[:attrs]) if data[:attrs]
          end
        end

        def update_config(config_data)
          @config_repository.current_update(config_data)
        rescue
          flash[:errors] << '全体設定の設定に失敗しました。'
          raise
        end

        def update_providers(provider_datas)
          existing_providers = @provider_repository.all.to_h { |provider| [provider.name, provider] }

          provider_datas.each_with_index do |provider_data, idx|
            provider_name = provider_data[:name]
            current_provider = existing_providers.delete(provider_name)

            data = {**provider_data, order: idx * 8}
            provider_params = data.delete(:params)

            provider =
              if current_provider
                @provider_repository.update(current_provider.id, data)
              else
                @provider_repository.create(data)
              end

            update_provider_params(provider, provider_params) if provider_params
          end

          # リストになかったプロバイダーを削除
          existing_providers.each_value do |provider|
            @provider_repository.delete(provider.id)
          end
        rescue
          flash[:errors] << 'プロバイダーの設定に失敗しました。'
          raise
        end

        def update_provider_params(provider, params)
          existing_params = @provider_param_repository.all_by_provider(provider).to_h { |param| [param.name, param] }

          provider.adapter_param_types.each do |param_type|
            param_name = param_type.name
            # 存在チェック
            next unless params.key?(param_name) && !(value = param_type.convert_value(params[param_type.name])).nil?

            current_param = existing_params.delete(param_name.to_s)
            param_data = {provider_id: provider.id, name: param_name.to_s,
                          value: param_type.dump_value(value),}
            if current_param
              @provider_param_repository.update(current_param.id, param_data)
            else
              @provider_param_repository.create(param_data)
            end
          end

          # リストになかったパラメーターを削除
          existing_params.each_value do |param|
            @provider_param_repository.delete(param.id)
          end
        end

        def update_attrs(attr_datas)
          named_providers = @provider_repository.all.to_h { |provider| [provider.name, provider] }
          @attr_repository.clear

          attr_datas.each_with_index do |attr_data, idx|
            data = attr_data.dup
            data[:order] = idx * 8

            data[:attr_mappings] = data[:attr_mappings]
              &.reject { |am_params| am_params[:key].nil? || am_params[:key].empty? }
              &.map do |am_params|
                {
                  **am_params.slice(:key, :conversion),
                  provider_id: named_providers[am_params[:provider]].id,
                }
              end
            @attr_repository.create_with_mappings(data)
          end
        rescue
          flash[:errors] << '属性の設定に失敗しました。'
          raise
        end
      end
    end
  end
end
