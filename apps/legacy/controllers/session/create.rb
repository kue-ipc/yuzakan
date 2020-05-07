# frozen_string_literal: true

module Legacy
  module Controllers
    module Session
      class Create
        include Legacy::Action

        def call(params)
          if authenticated?
            flash[:info] = '既にログインしています。'
            redirect_to routes.path(:dashboard)
          end

          result = Authenticate.new(client: remote_ip.to_s)
            .call(params[:session])

          if result.failure?
            flash[:errors] = result.errors
            flash[:failure] = 'ログインに失敗しました。'
            redirect_to routes.root_path
          end

          # セッション情報を保存
          session[:user_id] = result.user.id
          flash[:success] = 'ログインしました。'
          redirect_to routes.dashboard_path
        end

        def authenticate!
        end
      end
    end
  end
end
