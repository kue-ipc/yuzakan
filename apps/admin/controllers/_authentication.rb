# frozen_string_literal: true

module Admin
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
      check_session
      # TODO: 将来は管理者以外も権限があれば使用可能にする。
      # 現在のところ管理者のみログイン可能にする。
      !current_user.nil? && current_user.role&.admin
    end

    private def current_user
      return nil unless session[:user_id]

      @current_user ||= UserRepository.new.find_with_role(session[:user_id])
    end

    private def check_session
      if session[:access_time].nil? ||
         session[:access_time] + current_config&.session_timeout.to_i < Time.now
        session[:user_id] = nil
        flash[:warn] = 'セッションがタイムアウトしました。ログインし直してください。'
      end
      session[:access_time] = Time.now
    end
  end
end
