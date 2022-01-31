require_relative './connection'

module Web
  module Authentication
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.class_eval do
          before :authenticate!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    private def authenticate!
      return reply_unauthenticated unless authenticated?

      check_session!
    end

    private def authenticated?
      !current_user.nil?
    end

    private def check_session!
      return unless session_timeout?

      session[:user_id] = nil
      reply_session_timeout
    end

    private def session_timeout?
      timeout = current_config&.session_timeout || 3600
      return false if timeout.zero?

      Time.now - last_access_time > timeout
    end

    private def reply_unauthenticated
      flash[:warn] = 'ログインしてください。'
      redirect_to Web.routes.path(:root)
    end

    private def reply_session_timeout
      flash[:warn] = 'セッションがタイムアウトしました。'
      redirect_to Web.routes.path(:root)
    end
  end
end
