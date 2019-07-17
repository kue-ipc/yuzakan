# frozen_string_literal: true

module Admin
  module Configuration
    private def configurate!
      redirect_to routes.path(:setup) unless configurated?
    end

    private def configurated?
      !current_config.nil?
    end

    private def current_config
      @current_config ||= ConfigRepository.new.current
    end

    private def current_theme
      current_config&.theme || DEFAULT_THEME
    end
  end
end
