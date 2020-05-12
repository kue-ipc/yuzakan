# frozen_string_literal: true

module Web
  module RemoteIp
    include Configuration

    private def check_remote_ip!
      halt 403 unless allow_remote_ip?
    end

    private def allow_remote_ip?
      # 現行は常に許可
      true
    end

    private def remote_ip
      return @remote_ip if @remote_ip

      result = CheckRemoteIp.new(config: current_config).call(request: request)
      @remote_ip = result.remote_ip
    end
  end
end
