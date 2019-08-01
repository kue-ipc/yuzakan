# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

require 'ipaddress'

class CheckRemoteIp
  include Hanami::Interactor
  include Yuzakan::Utils::IPList

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:request) { filled? }
    end
  end

  expose :remote_ip

  def initialize(config: ConfigRepository.new.current)
    @config = config
  end

  def call(request:)
    remote_addr_ip = IPAddress(request.fetch_header('REMOTE_ADDR'))

    if @config && @config.remote_ip_header && @config.trusted_reverse_proxies &&
        include_net?(remote_addr_ip, @config.trusted_reverse_proxies)

      header = request.get_header(header_env_name(@config.remote_ip_header))
      @remote_ip = str_to_ips(header).first if header
    end

    @remote_ip ||= remote_addr_ip
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end
    true
  end

  private def header_env_name(name)
    "HTTP_#{name.upcase.tr('-', '_')}"
  end
end
