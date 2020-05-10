# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

require 'ipaddress'

class CheckRemoteIp
  include Hanami::Interactor

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
    @remote_ip = IPAddress(request.fetch_header('REMOTE_ADDR'))

    if @config&.remote_ip_header && @config&.trusted_reverse_proxies &&
       include_net?(@remote_ip, @config&.trusted_reverse_proxies)

      header = request.get_header(header_env_name(@config.remote_ip_header))
      @remote_ip = str_to_ips(header).first if header
    end
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

  private def str_to_ips(str, sep = /[,\s]\s*/)
    str.split(sep).map(&method(:IPAddress))
  end

  private def ips_to_str(ips, sep = ',')
    ips.map(&:to_string).join(sep)
  end

  private def include_net?(addr, networks)
    addr = IPAddress(addr) if addr.is_a?(String)
    networks = str_to_ips(networks) if networks.is_a?(String)
    networks.any? do |net|
      # 同じクラスでないとinclude?でのチェックでエラーになる。
      net.class == addr.class && net.include?(addr)
    end
  end

  private def ips_str_normalize(str)
    ips_to_str(str_to_ips(str))
  end
end
