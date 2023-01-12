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
                       user_repository: UserRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
          @network_repository ||= network_repository
          @provider_repository ||= provider_repository
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

              #   replace_providers_and_attrs if
              #   provider_repository = ProviderRepository.new
              #   attr_repository = AttrRepository.new
              #   # 削除
              #   provider_repository.all.each do |provider|
              #     provider_repository.delete(provider.id)
              #   end
              #   attr_repository.clear

              #   data[:providers].each do |provider_data|
              #     result = UpdateProvider.new(provider_repository: provider_repository).call(provider_data)
              #     if result.failure?
              #       flash[:errors].concat(result.errors)
              #       raise 'プロバイダーの設定に失敗しました。'
              #     end
              #   end

              #   data[:attrs].each do |attr_data|
              #     result = CreateAttr.new(attr_repository: attr_repository).call(attr_data)
              #     if result.failure?
              #       flash[:errors].concat(result.errors)
              #       raise '属性の設定に失敗しました。'
              #     end
              #   end
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
          current_providers = provider_repository.all.to_h { |provider| [provider.name, provider] }
          check_providers = current_providers.keys.to_set
          provider_datas.each do |provider_data|
            provider =
              if current_providers.key?(provider_data[:name])
                check_providers.delete(provider_data[:name])
                @provider_repository.update(@provider.id, provider_data.except(:params))
              else
                @provider_repository.create(provider_data.except(:params))
              end


            result = UpdateProvider.new(provider_repository: provider_repository).call(provider_data)
            if result.failure?
              flash[:errors].concat(result.errors)
              raise 'プロバイダーの設定に失敗しました。'
            end
          end
        end

        def update_attrs(attr_datas)
              #   provider_repository.all.each do |provider|
              #     provider_repository.delete(provider.id)
              #   end
              #   attr_repository.clear
            end
      end
    end
  end
end
