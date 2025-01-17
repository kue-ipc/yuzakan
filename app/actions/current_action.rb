# frozen_string_literal: true

module Yuzakan
  module Actions
    module CurrentAction
      include Dry::Monads[:maybe]

      private def current_time(_request, _response)
        @current_time ||= Maybe(Time.now)
      end

      private def current_uuid(request, _response)
        @current_uuid ||= Maybe(request.session[:uuid] || SecureRandom.uuid)
      end

      private def current_config(_request, _response)
        @current_config ||= Maybe(config_repo.current)
      end

      private def current_user(request, _response)
        @current_user ||= Maybe(user_repo.get(request.session[:user]))
      end
      # FIXME: unixドメイン経由やリバースプロキシ経由の場合の検証が必要。

      private def current_network(request, _response)
        @current_network ||= Maybe(network_repo.find_by_ip(request.ip))
      end

      private def current_level(request, response)
        @current_level ||= Maybe([
          current_user(request, response)&.clearance_level || 0,
          current_network(request, response)&.clearance_level || 0,
        ].min)
      end
    end
  end
end
