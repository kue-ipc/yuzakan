# frozen_string_literal: true

module Admin
  module Authentication
    private def authenticate!
      redirect_to routes.path(:new_session) unless authenticated?
    end

    private def authenticated?
      !current_user.nil?
    end

    private def current_user
      @current_user ||= UserRepository.new.find_with_role(session[:user_id])
    end
  end
end
