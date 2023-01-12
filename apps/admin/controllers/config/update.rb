# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Config
      class Update
        include Admin::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:config).schema do
              optional(:file)

              optional(:title).filled(:str?, max_size?: 255)
              optional(:domain).maybe(:str?, max_size?: 255)
              optional(:session_timeout).filled(:int?, gteq?: 0, lteq?: 24 * 60 * 60)
              optional(:password_min_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:password_max_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:password_min_score).filled(:int?, gteq?: 0, lteq?: 4)
              optional(:password_unusable_chars).maybe(:str?, max_size?: 128)
              optional(:password_extra_dict).maybe(:str?, max_size?: 4096)
              optional(:generate_password_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:generate_password_type).filled(:str?)
              optional(:generate_password_chars).maybe(:str?, format?: /^[\x20-\x7e]*$/, max_size?: 128)
              optional(:contact_name).maybe(:str?, max_size?: 255)
              optional(:contact_email).maybe(:str?, max_size?: 255)
              optional(:contact_phone).maybe(:str?, max_size?: 255)
            end
          end
        end

        class YamlValidator
          include Hanam::Validations

          predicates NamePredicates
          messages :i18n

          validations do
            optional(:config).schema do
              optional(:title).filled(:str?, max_size?: 255)
              optional(:domain).maybe(:str?, max_size?: 255)
              optional(:session_timeout).filled(:int?, gteq?: 0, lteq?: 24 * 60 * 60)
              optional(:password_min_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:password_max_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:password_min_score).filled(:int?, gteq?: 0, lteq?: 4)
              optional(:password_unusable_chars).maybe(:str?, max_size?: 128)
              optional(:password_extra_dict).maybe(:str?, max_size?: 4096)
              optional(:generate_password_size).filled(:int?, gteq?: 1, lteq?: 255)
              optional(:generate_password_type).filled(:str?)
              optional(:generate_password_chars).maybe(:str?, format?: /^[\x20-\x7e]*$/, max_size?: 128)
              optional(:contact_name).maybe(:str?, max_size?: 255)
              optional(:contact_email).maybe(:str?, max_size?: 255)
              optional(:contact_phone).maybe(:str?, max_size?: 255)
            end
            # rubocop:disable Layout/BlockEndNewline, Layout/MultilineBlockLayout, Style/BlockDelimiters
            optional(:providers) { array? { each { schema {
              required(:name).filled(:str?, :name?, max_size?: 255)
              optional(:display_name).maybe(:str?, max_size?: 255)
              required(:adapter_name).filled(:str?, :name?, max_size?: 255)
              optional(:readable).filled(:bool?)
              optional(:writable).filled(:bool?)
              optional(:authenticatable).filled(:bool?)
              optional(:password_changeable).filled(:bool?)
              optional(:lockable).filled(:bool?)
              optional(:individual_password).filled(:bool?)
              optional(:self_management).filled(:bool?)
              optional(:group).filled(:bool?)
              optional(:params) { hash? }
            } } } }
            optional(:attrs) { array? { each { schema {
              required(:name).filled(:str?, :name?, max_size?: 255)
              optional(:display_name).maybe(:str?, max_size?: 255)
              required(:type).filled(:str?)
              optional(:hidden).filled(:bool?)
              optional(:readonly).filled(:bool?)
              optional(:code).maybe(:str?, max_size?: 4096)
              optional(:attr_mappings) { array? { each { schema {
                required(:provider).filled(:str?, :name?, max_size?: 255)
                required(:name).maybe(:str?, max_size?: 255)
                optional(:conversion) { none? | included_in?(AttrMapping::CONVERSIONS) }
              } } } }
            } } } }
            # rubocop:enable Layout/BlockEndNewline, Layout/MultilineBlockLayout, Style/BlockDelimiters
          end
        end

        params Params

        expose :config

        def initialize(config_repository: ConfigRepository.new,
                       network_repository: NetworkRepository.new,
                       provider_repository: ProviderRepository.new,
                       provider_param_repository: ProviderParamRepository.new,
                       attr_repository: AttrRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
          @network_repository ||= network_repository
          @provider_repository ||= provider_repository
          @provider_param_repository ||= provider_param_repository
          @attr_repository ||= attr_repository
          @user_repository ||= user_repository
        end

        def call(params)
          flash[:errors] ||= []

          @config = current_config.merge(params[:config])

          unless params.valid?
            flash[:errors] << params.errors
            flash[:error] = '設定に失敗しました。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          if @config[:file]
            import_yaml(@config[:file][:tempfile])
          else
            update_config(@config)
          end

          unless flash[:errors].empty?
            flash[:failure] = '設定に失敗しました。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          flash[:success] = '設定を更新しました。'
          redirect_to routes.path(:edit_config)
        end

        def import_yaml(file)
          if file.nil?
            flash[:errors] << 'ファイルが選択されていません。'
            return
          end

          begin
            yaml = file.read
            data = YAML.safe_load(yaml, [Symbol, Time, Date], symbolize_names: true)
            validate_result = YamlValidator.new(data).validate

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
