# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class FindNetwork
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages :i18n

    validations do
      required(:ip).filled(:str?)
    end
  end

  expose :network

  def initialize(network_repository: NetworkRepository.new)
    @network_repository = network_repository
  end

  def call(params)
    ip = params[:ip]
    # unixドメインは127.0.0.1と同じとみなす
    ip = '127.0.0.1' if ip.include?('unix')

    ip_addr = IPAddr.new(ip)

    @network = @network_repository.all.find { |network| network.include?(ip) }
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      Hanami.logger.error "[#{self.class.name}] Validation fails: #{validation.messages}"
      error(validation.messages)
      return false
    end

    true
  end
end
