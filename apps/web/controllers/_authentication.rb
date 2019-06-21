# frozen_string_literal: true

module Web
  module Authentication
    private def authenticate!
      redirect_to routes.new_session_path unless authenticated?
    end

    private def authenticated?
      !current_user.nil?
    end

    private def current_user
      if session[:access_time].nil? ||
         session[:access_time] + current_config&.session_timeout.to_i < Time.now
        session[:user_id] = nil
      end
      session[:access_time] = Time.now
      @current_user ||= session[:user_id] &&
                        UserRepository.new.find(session[:user_id])
    end
  end
end
