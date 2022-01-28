module Web
  module Connection
    private def current_config
      @current_config ||= ConfigRepository.new.current
    end

    private def remote_ip
      @remote_ip ||= request.ip
    end

    private def current_user
      @current_user ||= (session[:user_id] && UserRepository.new.find(session[:user_id]))
    end

    private def last_access_time
      @last_access_time ||= (session[:access_time] || Time.now).tap do
        session[:access_time] = Time.now
      end
    end
  end
end
