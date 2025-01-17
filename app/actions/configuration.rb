# frozen_string_literal: true

module Yuzakan
  module Actions
    module Configuration
      def self.included(action)
        action.include Conneciton unless action.include?(Connection)
        action.before :configurate!
      end

      private def configurate!(request, response)
        return if configurated?(request, response)

        reply_uninitialized(request, response)
      end

      private def configurated?(request, response)
        !response["current_config"].nil?
      end

      private def reply_uninitialized(request, response)
        response.redirect_to(Hanami.app["routes"].path(:root))
      end
    end
  end
end
