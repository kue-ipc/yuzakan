# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations/form'

require 'ipaddress'

class UpdateConfig
  include Hanami::Interactor
  include Yuzakan::Utils::IPList

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:title) { str? & max_size?(255) }

      required(:session_timeout) { int? & gteq?(0) }

      required(:theme) { max_size?(255) }

      required(:password_min_size) { int? & gteq?(1) & lteq?(255) }
      required(:password_max_size) { int? & gteq?(1) & lteq?(255) }
      required(:password_strength) { int? & gteq?(0) & lteq?(4) }

      required(:remote_ip_header)
      required(:trusted_reverse_proxies)

      required(:admin_networks)
    end
  end

  def initialize(config_repository: ConfigRepository.new)
    @config_repository = config_repository
  end

  def call(params)
    @config_repository.update(@config_repository.current.id,
      params
    )
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(params: validation.messages)
      return false
    end
    true
  end

  private def check_ip_addr_list(list_str)
    list = list_str.split(/[,\s]\s*/).reject(&:empty?)
    ip_list = list.map { |str| IPAddr.new(str) }
  end
end
