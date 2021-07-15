module Admin
  module Controllers
    module Config
      class Import
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          pp params[:config]
          file = params.dig(:config, :file, :tempfile)
          if file.nil?
            flash[:errors] = 'ファイルが選択されていません。'
          else
            yaml = file.read
            data = YAML.safe_load(yaml, [Symbol, Time, Date], symbolize_names: true)
            pp data
            file.close!
            # result = UpdateConfig.new.call(params[:config])

            # if result.successful?
            #   flash[:successes] = ['設定を変更しました。']
            # else
            #   flash[:errors] = result.errors
            #   flash[:errors] << '変更に失敗しました。'
            # end
          end

          redirect_to routes.path(:dashboard)
        end
      end
    end
  end
end
