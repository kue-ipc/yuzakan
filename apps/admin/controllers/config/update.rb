module Admin
  module Controllers
    module Config
      class Update
        include Admin::Action

        def call(params)
          result = UpdateConfig.new.call(params[:config])

          if result.successful?
            flash[:successes] = ['設定を変更しました。']
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
