# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

require 'ipaddr'

class CheckClientIp
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:request) { filled? }
    end
  end

  expose :client_ip

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(request:, header: nil, trusted_networks: nil, allowed_networks: nil,
           denied_networks: nil)
    remote_ip = IPAddr.new(request.env('REMOTE_ADDR'))
    if header&.size&.positive? && trusted_networks&.size&.positive? &&
        network_include?(remote_ip, split_address(trusted_networks))
      header_ips = request.env(header)
      if header_ips&.size&.positive?
        @client_ip = split_address(header_ips).first
      end
    end
    @client_ip ||= remote_ip
    if denied_networks&.size&.positive?
      network_include?(client_ip, split_address(denied_networks))
    end












    @provider = @provider_repository.find_with_params(provider_id.to_i)
    if @provider.nil?
      error('該当のプロバイダーがありません。')
      return
    end
    unless @provider.adapter.check
      error('チェックに失敗しました。')
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(params: validation.messages)
      return false
    end
    true
  end
end
