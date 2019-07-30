# frozen_string_literal: true

module Web
  module Configuration
    private def configurate!
      redirect_to routes.path(:maintenance) unless configurated?
      redirect_to routes.path(:maintenance) if maintenance?
    end

    private def configurated?
      !current_config.nil?
    end

    private def maintenance?
      current_config&.maintenance
    end

    private def current_config
      @current_config ||= ConfigRepository.new.current
    end

    private def current_theme
      current_config&.theme || DEFAULT_THEME
    end
  end
end
