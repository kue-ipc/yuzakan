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
      optional(:title) { str? & max_size?(255) }

      optional(:session_timeout) { int? & gteq?(0) & lteq?(24 * 60 * 60)}

      optional(:theme) { max_size?(255) }

      optional(:password_min_size) { int? & gteq?(1) & lteq?(255) }
      optional(:password_max_size) { int? & gteq?(1) & lteq?(255) }
      optional(:password_min_score) { int? & gteq?(0) & lteq?(4) }

      optional(:remote_ip_header)
      optional(:trusted_reverse_proxies)

      optional(:admin_networks)
    end
  end

  def initialize(config_repository: ConfigRepository.new)
    @config_repository = config_repository
  end

  def call(params)
    @config_repository.update(@config_repository.current.id, params)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    unless params&.size&.positive?
      error('変更箇所がありません。')
      return false
    end

    true
  end
end
