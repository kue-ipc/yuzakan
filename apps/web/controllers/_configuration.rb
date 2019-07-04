# frozen_string_literal: true

module Web
  module Configuration
    private def configurate!
      redirect_to routes.path(:maintenance) unless configurated?
    end

    private def configurated?
      !current_config.nil?
    end

    private def current_config
      @current_config ||= ConfigRepository.new.current
    end
  end
end
