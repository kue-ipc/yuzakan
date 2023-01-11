# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Config
      class Update
        include Admin::Action

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

        params Params

        expose :config

        def call(params)
          flash[:errors] ||= []

          @config = current_config.merge(params[:config])

          unless params.valid?
            flash[:errors] << params.errors
            flash[:failure] = '設定に失敗しました。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          if @config[:file]
            import_yaml
          else
            update_config
          end
        end

        def import_yaml
          file = @config[:file][:tempfile]
          if file.nil?
            flash[:errors] << 'ファイルが選択されていません。'
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          begin
            yaml = file.read
            data = YAML.safe_load(yaml, [Symbol, Time, Date],
                                  symbolize_names: true)

            config_repository = ConfigRepository.new
            config_repository.transaction do
              result = UpdateConfig.new(config_repository: config_repository).call(data[:config])
              if result.failure?
                flash[:errors].concat(result.errors)
                raise '全体設定の設定に失敗しました。'
              end

              provider_repository = ProviderRepository.new
              attr_repository = AttrRepository.new
              # 削除
              provider_repository.all.each do |provider|
                provider_repository.delete(provider.id)
              end
              attr_repository.clear

              data[:providers].each do |provider_data|
                result = UpdateProvider.new(provider_repository: provider_repository).call(provider_data)
                if result.failure?
                  flash[:errors].concat(result.errors)
                  raise 'プロバイダーの設定に失敗しました。'
                end
              end

              data[:attrs].each do |attr_data|
                result = CreateAttr.new(attr_repository: attr_repository).call(attr_data)
                if result.failure?
                  flash[:errors].concat(result.errors)
                  raise '属性の設定に失敗しました。'
                end
              end
            end
            flash[:success] = 'インポートに成功しました。'
          rescue => e
            Hanami.logger.error e
            flash[:errors] << e.message
            flash[:errors] << 'インポートに失敗しました。'
          ensure
            file.close!
          end

          redirect_to routes.path(:root)
        end

        def update_config
          result = UpdateConfig.new.call(@config)

          if result.successful?
            flash[:success] = '設定を変更しました。'
          else
            flash[:errors] = result.errors
            flash[:errors] << '変更に失敗しました。'
          end

          redirect_to routes.path(:edit_config)
        end
      end
    end
  end
end
