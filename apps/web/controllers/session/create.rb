# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class Create
        include Web::Action
        expose :data

        def call(params)
          result = Authenticate.new.call(params[:session])

          if result.successful?
            session[:user_id] = result.user.id
            session[:access_time] = Time.now
          end

          case format
          when :html
            if result.successful?
              flash[:successes] = ['ログインしました。']
              redirect_to routes.path(:dashboard)
            else
              flash[:errors] = result.errors
              redirect_to routes.path(:new_session)
            end
          when :json
            if result.successful?
              @data = {
                result: 'success',
                message: ['ログインしました。']
              }
            else
              @data = {
                result: 'failure',
                message: result.errors
              }
            end
          end
        end

        def authenticate!; end
      end
    end
  end
end
