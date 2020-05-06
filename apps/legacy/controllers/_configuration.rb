# frozen_string_literal: true

module Legacy
  module Configuration
    include Yuzakan::Utils::IPList

    private def configurate!
      redirect_to Web.routes.maintenance_path if !configurated? || maintenance?
    end

    private def configurated?
      !current_config.nil?
    end

    private def current_config
      @current_config ||= ConfigRepository.new.current
    end

    private def maintenance?
      current_config&.maintenance
    end

    private def check_session!
      if session[:user_id] && session_timeout?
        session[:user_id] = nil
        flash[:warn] = 'セッションがタイムアウトしました。' \
                       'ログインし直してください。'
        session[:access_time] = Time.now
        redirect_to routes.root_path
        return
      end

      session[:access_time] = Time.now
    end

    private def session_timeout?
      time = session[:access_time]
      return true if time.nil?

      timeout = current_config&.session_timeout || 3600
      return false if timeout.zero?

      Time.now - time > timeout
    end

    private def check_remote_ip!
      halt 403 unless allow_remote_ip?
    end

    private def allow_remote_ip?
      true
    end

    private def remote_ip
      @remote_ip ||=
        CheckRemoteIp.new(config: current_config).call(request: request)
          .remote_ip
    end
  end
end
