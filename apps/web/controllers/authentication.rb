module Web
  module Authentication
    private def authenticate!
      return if authenticated?

      if format == :html
        redirect_to routes.path(:root)
      else
        halt 401
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
