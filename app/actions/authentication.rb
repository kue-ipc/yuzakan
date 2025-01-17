# frozen_string_literal: true

module Yuzakan
  module Actions
    module Authentication
      def self.included(action)
        action.include Conneciton unless action.include?(Connection)
        action.before :authenticate!
      end

      private def authenticate!(request, response)
        return if response[:security_level]&.zero?
        return if authenticated?(request, response)

        reply_unauthenticated(request, response)
      end

      private def authenticated?(_request, response)
        !response[:current_user].nil?
      end

      private def reply_unauthenticated(_request, response)
        response.flash[:warn] ||= I18n.t("messages.unauthenticated")
        response.redirect_to(Hanami.app["routes"].path(:root))
      end
    end
  end
end
