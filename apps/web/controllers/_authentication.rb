# frozen_string_literal: true

module Web
  module Authentication
    private def authenticate!
      unless authenticated?
        if format == :html
          redirect_to routes.new_session_path
        else
          halt 401
        end
      end
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
