require 'hanami/interactor'
require 'hanami/validations'

class CheckIp
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:ip) { filled? }
    end
  end

  def initialize(allowed_networks:)
    @allowed_networks =
      if allowed_networks.is_a?(String)
        allowed_networks.split(/[\s,;]+/)
      else
        allowed_networks
      end
  end

  def call(params)
    ip = params[:ip]
    # unixドメインは常に許可
    return if ip.include?('unix')

    ip_addr = IPAddr.new(ip)

    allowed = @allowed_networks.any? do |network|
      IPAddr.new(network).include?(ip_addr)
    end
    error!('許可されていないネットワークからの接続です。') unless allowed
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end
end
