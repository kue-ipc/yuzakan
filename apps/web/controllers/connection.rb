module Web
  module Connection
    def self.included(action)
      return unless action.is_a?(Class)

      action.class_eval do
        before :connect!
        # after :done!
        expose :current_config
        expose :current_user
      end
    end

    def initialize(activity_repository: ActivityRepository.new,
                   config_repository: ConfigRepository.new,
                   user_repository: UserRepository.new,
                   **opts)
      super(**opts)
      @activity_repository ||= activity_repository
      @config_repository ||= config_repository
      @user_repository ||= user_repository
    end

    private def connect!
      @log_info = {
        config_revision: current_config&.updated_at&.to_i,
        maintenance: current_config&.maintenance,
        user: current_user,
        client: remote_ip,
        last_access_time: last_access_time,
        action: self.class.name,
        method: request.request_method,
        path: request.path,
        params: params.to_h,
      }

      Hanami.logger.info(@log_info)

      current_config
      last_access_time
    end

    # private def done!
    #   @activity_repository.create(**activity_params, result: params)
    # end

    private def current_config
      @current_config ||= @config_repository.current
    end

    private def remote_ip
      @remote_ip ||= request.ip
    end

    private def current_user
      @current_user ||= (session[:user_id] && @user_repository.find(session[:user_id]))
    end

    private def last_access_time
      @last_access_time ||= (session[:access_time] || Time.now).tap do
        session[:access_time] = Time.now
      end
    end
  end
end
