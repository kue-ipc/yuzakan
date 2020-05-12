# frozen_string_literal: true

module Admin
  module Authentication
    private def authenticate!
      unless authenticated?
        # セッションを初期化しておく
        session[:user_id] = nil
        if format == :html
          redirect_to routes.root_path
        else
          halt 401
        end
      end
    end

    private def authenticated?
      !current_user.nil? && current_user.role&.admin
    end

    private def current_user
      return nil unless session[:user_id]

      @current_user ||= UserRepository.new.find_with_role(session[:user_id])
    end
  end
end
