# frozen_string_literal: true

module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action

        def call(params)
          result = Authenticate.new.call(params[:session])
          if result.successful?
            session[:user_id] = result.user.id
          else
            flash[:errors] = result.errors
            redirect_to routes.path(:new_session)
          end
          flash[:successes] = ['ログインしました。']
        end

        def authenticate!; end
      end
    end
  end
end
