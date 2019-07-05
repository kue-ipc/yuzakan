# frozen_string_literal: true

require 'ipaddr'

module Admin
  module RemoteIp
    include Configuration

    private def check_remote_ip!
      halt 403 unless allow_remote_ip?
    end

    private def allow_remote_ip?
      admin_nework_repository = AdminNetworkRepository.new

      # リストが空の場合は制限しない。
      return true if admin_nework_repository.count.zero?

      admin_network_repository.any? do |network|
        IPAddr.new(network.address).include?(remote_ip)
      end
    end

    private def remote_ip
      @remote_ip ||= [current_config&.remote_ip_header, 'REMOTE_ADDR']
        .compact
        .lazy
        .map { |name| request.get_header(name)&.split&.last }
        .find.first
        .tap(&method(:pp))
        &.then(&IPAddr.method(:new))
    end
  end
end
