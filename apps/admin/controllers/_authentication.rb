# frozen_string_literal: true

module Admin
  module Authentication
    private def authenticate!
      unless authenticated?
        if format == :html
          redirect_to routes.root_path
        else
          halt 401
        end
      end
      administrate!
    end

    private def authenticated?
      !current_user.nil?
    end

    private def current_user
      return nil unless session[:user_id]

      @current_user ||= UserRepository.new.find(session[:user_id])
    end

    private def administrate!
      unless current_user&.admin
        # 管理者では無い場合は、セッションを削除する。
        session[:user_id] = nil
        if format == :html
          flash[:error] = '管理者権限がありません。'
          redirect_to routes.root_path
        else
          halt 401
        end
      end
    end
  end
end
