# frozen_string_literal: true

module Admin
  module Authentication
    private def authenticate!
      unless authenticated?
        flash[:warns] = ['ログインが必要です。']
        redirect_to routes.path(:new_session)
      end
    end

    private def authenticated?
      # TODO: 将来は管理者以外も権限があれば使用可能にする。
      # 現在のところ管理者のみログイン可能にする。
      !current_user.nil? && current_user.role&.admin
    end

    private def current_user
      @current_user ||= UserRepository.new.find_with_role(session[:user_id])
    end
  end
end
