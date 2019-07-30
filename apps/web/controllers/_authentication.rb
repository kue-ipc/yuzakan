# frozen_string_literal: true

module Web
  module Authentication
    private def authenticate!
      unless authenticated?
        if format == :html
          redirect_to routes.new_session_path
        else
          halt 401
        end
      end
    end

    private def authenticated?
      check_session
      !current_user.nil?
    end

    private def current_user
      return nil unless session[:user_id]

      @current_user ||= UserRepository.new.find(session[:user_id])
    end

    private def check_session
      if session[:access_time].nil? ||
         session[:access_time] + current_config&.session_timeout.to_i < Time.now
        session[:user_id] = nil
        flash[:warn] = 'セッションがタイムアウトしました。ログインし直してください。'
      end
      session[:access_time] = Time.now
    end
  end
end
