# frozen_string_literal: true

module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action

        def call(params)
          result = Authenticate.new.call(params[:session])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.new_session_path
          end

          role = RoleRepository.new.find(result.user.role_id)

          unless role&.admin
            flash[:warn] = '権限がありません。'
            redirect_to routes.new_session_path
          end

          session[:user_id] = result.user.id
          flash[:successes] = ['ログインしました。']
        end

        def authenticate!; end
      end
    end
  end
end
