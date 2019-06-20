# frozen_string_literal: true

module Web
  module Configuration
    private def configurate!
      flash[:warns] ||= []
      flash[:warns] << '現在ベータ版です。不具合がある場合は管理者にお問い合わせください。'
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
