module Admin
  module Configuration
    private def configurate!
      redirect_to routes.path(:setup) unless configurated?
      check_ip!
      check_session!
    end

    private def current_config
      @current_config ||= ConfigRepository.new.current
    end

    private def remote_ip
      @remote_ip ||= request.ip
    end

    private def configurated?
      !current_config.nil?
    end

    private def maintenance?
      current_config&.maintenance
    end

    private def check_ip!
      halt 403 unless check_ip?
    end

    private def check_ip?
      admin_networks = current_config.admin_networks
      return true if admin_networks.empty?

      result = CheckIp.new(allowed_networks: admin_networks).call(ip: remote_ip)
      result.successful?
    end

    private def check_session!
      if session[:user_id] && session_timeout?
        session[:user_id] = nil
        flash[:warn] = 'セッションがタイムアウトしました。' \
                       'ログインし直してください。'
        session[:access_time] = Time.now
        redirect_to routes.path(:root)
        return
      end

      session[:access_time] = Time.now
    end

    private def session_timeout?
      time = session[:access_time]
      return true if time.nil?

      timeout = current_config.session_timeout || 3600
      return false if timeout.zero?

      Time.now - time > timeout
    end
  end
end
