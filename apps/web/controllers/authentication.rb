# frozen_string_literal: true

module Web
  module Authentication
    private def authenticate!
      redirect_to routes.new_session_path unless authenticated?
    end

    private def authenticated?
      !current_user.nil?
    end

    private def current_user
      @current_user ||= UserRepository.new.find(session[:user_id])
    end
  end
end