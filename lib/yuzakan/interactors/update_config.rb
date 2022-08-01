require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateConfig
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages :i18n

    validations do
      optional(:title).filled(:str?, max_size?: 255)
      optional(:domain).filled(:str?, max_size?: 255)
      optional(:session_timeout) { int? & gteq?(0) & lteq?(24 * 60 * 60) }

      optional(:password_min_size) { int? & gteq?(1) & lteq?(255) }
      optional(:password_max_size) { int? & gteq?(1) & lteq?(255) }
      optional(:password_min_score) { int? & gteq?(0) & lteq?(4) }
      optional(:password_unusable_chars) { str? & max_size?(128) }
      optional(:password_extra_dict) { str? & max_size?(4096) }

      optional(:generate_password_size) { int? & gteq?(1) & lteq?(255) }
      optional(:generate_password_type) { int? & gteq?(0) & lteq?(4) }
      optional(:generate_password_chars) { str? & max_size?(128) }

      optional(:contact_name) { none? | (str? & max_size?(1024)) }
      optional(:contact_email) { none? | (str? & max_size?(1024)) }
      optional(:contact_phone) { none? | (str? & max_size?(1024)) }
    end
  end

  def initialize(config_repository: ConfigRepository.new)
    @config_repository = config_repository
  end

  def call(params)
    @config_repository.current_update(params)
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
