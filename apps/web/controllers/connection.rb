module Web
  module Connection
    def self.included(action)
      if action.is_a?(Class)
        action.define_singleton_method(:security_level) do |level = nil|
          if level
            @level = level
          else
            @level || default_security_level
          end
        end
        action.define_singleton_method(:default_security_level) { 1 }

        action.class_eval do
          before :connect!
          before :check_session!
          after :done!
          expose :current_config
          expose :current_user
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    def initialize(activity_log_repository: ActivityLogRepository.new,
                   config_repository: ConfigRepository.new,
                   user_repository: UserRepository.new)
      @activity_log_repository = activity_log_repository
      @config_repository = config_repository
      @user_repository = user_repository
    end

    private def connect!
      @log_info = {
        config_revision: current_config&.updated_at&.to_i,
        maintenance: current_config&.maintenance,
        username: current_user&.name,
        client: remote_ip,
        last_access_time: last_access_time,
        action: self.class.name,
        method: request.request_method,
        path: request.path,
      }

      Hanami.logger.info(@log_info)

      current_config
      last_access_time
    end

    private def done!
      @activity_log_repository.create(**@log_info, status: response[0])
    end

    private def current_config
      @current_config ||= @config_repository.current
    end

    private def remote_ip
      @remote_ip ||= request.ip
    end

    private def current_user
      @current_user ||= (session[:user_id] && @user_repository.find(session[:user_id]))
    end

    private def current_user_level
      if current_user&.admin
        5
      elsif current_user
        2
      else
        0
      end
    end

    private def last_access_time
      @last_access_time ||= (session[:access_time] || Time.now).tap do
        session[:access_time] = Time.now
      end
    end

    def security_level
      self.class.security_level
    end

    private def allowed_networks
      if security_level >= 3
        current_config.admin_networks
      else
        current_config.user_networks
      end
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

    private def reply_session_timeout
      flash[:warn] = 'セッションがタイムアウトしました。'
      redirect_to Web.routes.path(:root)
    end
  end
end
