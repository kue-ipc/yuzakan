# frozen_string_literal: true

require 'ipaddr'

module Admin
  module RemoteIp
    include Configuration
    include Yuzakan::Utils::IPList

    private def check_remote_ip!
      halt 403 unless allow_remote_ip?
    end

    private def allow_remote_ip?
      # 未設定の場合は常に許可
      return true unless current_config&.admin_networks&.size&.positive?

      include_net?(remote_ip, current_config.admin_networks)
    end

    private def remote_ip
      return @remote_ip if @remote_ip

      result = CheckRemoteIp.new(config: current_config).call(request: request)
      @remote_ip = result.remote_ip
    end
  end
end
