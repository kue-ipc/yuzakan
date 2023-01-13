# frozen_string_literal: true

require_relative '../../../../lib/yuzakan/validators/config_validator'
require_relative '../../../../lib/yuzakan/validators/provider_validator'
require_relative '../../../../lib/yuzakan/validators/attr_validator'

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
                required(:tempfile) { size?(1..) }
              end
            end
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

          pp params.to_h
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
          flash[:errors] << e.message
          flash[:error] = 'エラーが発生しました。'
          self.body = Admin::Views::Config::Edit.render(exposures)
        end

        def import_yaml(upload_file)
          begin
            yaml = upload_file[:tempfile].read
            data = YAML.safe_load(yaml, permitted_classes: [Symbol, Time, Date],
                                        filename: upload_file[:filename],
                                        symbolize_names: true)
          rescue Psych::SyntaxError => e
            flash[:errors] << 'YAMLファイルの形式が不正です。'
            flash[:errors] << e.message
            return
          end

          validate_result = YamlValidator.new(data).validate
          if validate_result.failure?
            flash[:errors] << 'インポートするファイルのパラメーターが不正です。'
            flash[:errors] << {file: validate_result.messages}
            return
          end

          data = validate_result.output

          begin
            if validate_result.failure?
              flash[:errors] << {file: validate_result.messages}
              raise 'インポートするファイルのパラメーターが不正です。'
            end
            data = validate_result.output

            @config_repository.transaction do
              update_config(data[:config]) if data[:config]
              raise '全体設定の設定に失敗しました。' unless flash[:errors].empty?

              update_providers(data[:providers]) if data[:providers]
              raise 'プロバイダーの設定に失敗しました。' unless flash[:errors].empty?

              update_attrs(data[:attrs]) if data[:attrs]
              raise '属性の設定に失敗しました。' unless falsh[:errors].empty?
            end
          rescue => e
            Hanami.logger.error e
            flash[:errors] << e.message
            flash[:errors] << 'インポートに失敗しました。'
          ensure
            file.close!
          end
        end

        def update_config(config_data)
          @config_repository.current_update(config_data)
        end

        def update_providers(provider_datas)
          existing_providers = named_providers.dup
          # プロバイダーのリストは初期化しておく
          @named_providers = {}

          provider_datas.each_with_index do |provider_data, idx|
            provider_name = provider_data[:name]
            current_provider = existing_providers.delete(provider_name)

            data = provider_data.dup
            provider_params = provider_data.delete[:params]
            data[:order] = idx * 8

            provider =
              if current_provider
                @provider_repository.update(current_provider.id, data)
              else
                @provider_repository.create(data)
              end
            # プロバイダーのリストを作り直す
            @named_providers[:provider_name] = provider

            next unless provider_params

            existing_params = provider.params.dup
            provider.adapter_param_types.each do |param_type|
              value = param_type.convert_value(existing_params[param_type.name])
              next if value.nil?

              data = {name: param_type.name.to_s, value: param_type.dump_value(value)}

              if existing_params.key?(param_type.name)
                current_value = existing_params.delete(param_type.name)

                if current_value != value
                  param_name = param_type.name.to_s
                  existing_provider_param = provider.provider_params.find { |param| param.name == param_name }
                  if existing_provider_param
                    @provider_param_repository.update(existing_provider_param.id, data)
                  else
                    # 名前がないということはあり得ない？
                    @provider_repository.add_param(provider, data)
                  end
                end
              else
                @provider_repository.add_param(provider, data)
              end
            end
            existing_params.each_key do |key|
              @provider_repository.delete_param_by_name(provider, key.to_s)
            end
          end

          # リストになかったプロバイダーを削除
          existing_providers.each_value { |provider| @provider_repository.delete(provider.id) }
        end

        def update_attrs(attr_datas)
          @attr_repository.clear

          attr_datas.each_with_index do |attr_data, idx|
            data = attr_data.dup
            data[:oredr] = idx * 8

            data[:attr_mappings] = data[:attr_mappings]
              &.reject { |am_params| am_params[:name].nil? || am_params[:name].empty? }
              &.map do |am_params|
                {
                  **am_params.slice(:name, :conversion),
                  provider_id: provider_id_by_name(am_params[:provider]),
                }
              end

            @attr_repository.create_with_mappings(params)
          end
        end

        private def named_providers
          @named_providers ||= @provider_repository.all.to_h { |provider| [provider.name, provider] }
        end

        private def provider_id_by_name(name)
          named_providers[name]
        end
      end
    end
  end
end
