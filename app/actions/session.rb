# frozen_string_literal: true

require "securerandom"

module Yuzakan
  module Actions
    module Session
      def self.included(action)
        action.before :check_session!
      end

      private def session!(request, response)
        return if request.session[:user_id].nil?
        return unless session_timeout?(request, response)

        session[:updated_at] = current_time if current_config && current_user

        response.session[:user_id] = nil
        response.session[:created_at] = nil
        response.session[:updated_at] = nil

        reply_session_timeout(request, response)
      end

      private def session_timeout?(request, response)
        return true if request.session[:updated_at].nil?

        timeout = current_config&.session_timeout || 3600
        timeout.zero? || current_time - session[:updated_at] > timeout
      end

      private def reply_session_timeout(request, response)
        flash[:warn] = I18n.t("messages.session_timeout")
        response.redirect_to(Hanami.app["routes"].path(:root))
      end
    end
  end
end
