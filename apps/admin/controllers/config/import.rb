module Admin
  module Controllers
    module Config
      class Import
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          flash[:errors] = []

          file = params.dig(:config, :file, :tempfile)
          if file.nil?
            flash[:errors] << 'ファイルが選択されていません。'
          else
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
                  next if provider.immutable

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
                  result = UpdateAttr.new(attr_repository: attr_repository).call(attr_data)
                  if result.failure?
                    flash[:errors].concat(result.errors)
                    raise '属性の設定に失敗しました。'
                  end
                end
              end
              flash[:success] = ['インポートに成功しました。']
            rescue => e
              Hanami.logger.error e.full_message
              flash[:errors] << e.message
              flash[:errors] << 'インポートに失敗しました。'
            ensure
              file.close!
            end
          end

          redirect_to routes.path(:dashboard)
        end
      end
    end
  end
end
