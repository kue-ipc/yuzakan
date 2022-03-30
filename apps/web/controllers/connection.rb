require 'securerandom'

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
          before :check_session!
          before :connect!
          after :done!
          expose :current_config
          expose :current_user
          expose :current_level
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    # その他のオプションはここで捨てる。
    def initialize(activity_log_repository: ActivityLogRepository.new,
                   config_repository: ConfigRepository.new,
                   user_repository: UserRepository.new,
                   **_opts)
      @activity_log_repository = activity_log_repository
      @config_repository = config_repository
      @user_repository = user_repository
    end

    private def connect!
      session[:updated_at] = current_time if current_config && current_user

      @log_info = {
        uuid: uuid,
        client: client,
        username: current_user&.name,
        action: self.class.name,
        method: request.request_method,
        path: request.path,
      }
      Hanami.logger.info(@log_info)
    end

    private def done!
      @activity_log_repository.create(**@log_info, status: response[0])
    end

    private def current_config
      @current_config ||= @config_repository.current
    end

    private def uuid
      @uuid ||= session[:uuid] ||= SecureRandom.uuid
    end

    private def client
      request.ip
    end

    private def current_user
      @current_user ||= (session[:user_id] && @user_repository.find(session[:user_id]))
    end

    private def current_level
      return @current_level if @current_level

      @current_level = current_user&.clearance_level || 0
      @current_level = 1 if @current_level >= 2 && !allowed_admin_networks?
      @current_level = 0 if @current_level >= 1 && !allowed_user_networks?
      @current_level
    end

    private def allowed_admin_networks?
      !current_config&.admin_networks&.size&.positive? ||
      CheckIp.new(allowed_networks: current_config.admin_networks).call(ip: client).successful?
    end

    private def allowed_user_networks?
      !current_config&.user_networks&.size&.positive? ||
      CheckIp.new(allowed_networks: current_config.user_networks).call(ip: client).successful?
    end

    private def current_time
      @current_time ||= Time.now
    end

    def security_level
      self.class.security_level
    end

    private def check_session!
      return if session[:user_id].nil?
      return unless session_timeout?

      session[:user_id] = nil
      session[:created_at] = nil
      session[:updated_at] = nil
      @current_user = nil

      reply_session_timeout
    end

    private def session_timeout?
      return true if session[:updated_at].nil?

      timeout = current_config&.session_timeout || 3600
      timeout.zero? || current_time - session[:updated_at] > timeout
    end

    private def reply_session_timeout
      flash[:warn] = 'セッションがタイムアウトしました。'
      redirect_to Web.routes.path(:root)
    end
  end
end
