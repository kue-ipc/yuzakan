require_relative './connection'

module Web
  module Authentication
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.class_eval do
          before :authenticate!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    private def authenticate!
      return if security_level.zero?

      reply_unauthenticated unless authenticated?
    end

    private def authenticated?
      !current_user.nil?
    end

    private def reply_unauthenticated
      flash[:warn] ||= 'ログインしてください。'
      redirect_to Web.routes.path(:root)
    end
  end
end
