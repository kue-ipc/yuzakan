# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class Create
        include Web::Action

        def call(params)
          result = Login.new.call(params[:session])
          if result.successful?
            session[:user_id] = result.user.id
            session[:access_time] = Time.now
          else
            flash[:errors] = result.errors
            redirect_to routes.path(:new_session)
          end
          flash[:successes] = ['ログインしました。']
          redirect_to routes.path(:dashboard)
        end

        def authenticate!; end
      end
    end
  end
end
