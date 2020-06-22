# frozen_string_literal: true

module Legacy
  module Authentication
    private def authenticate!
      redirect_to routes.path(:root) unless authenticated?
    end

    private def authenticated?
      !current_user.nil?
    end

    private def current_user
      return nil unless session[:user_id]

      @current_user ||= UserRepository.new.find(session[:user_id])
    end
  end
end
