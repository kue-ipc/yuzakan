require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateConfig
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages :i18n

    validations do
      optional(:title).filled(:str?, max_size?: 255)
      optional(:domain).maybe(:str?, max_size?: 255)
      optional(:session_timeout).filled(:int?, gteq?: 0, lteq?: 24 * 60 * 60)

      optional(:password_min_size).filled(:int?, gteq?: 1, lteq?: 255)
      optional(:password_max_size).filled(:int?, gteq?: 1, lteq?: 255)
      optional(:password_min_score).filled(:int?, gteq?: 0, lteq?: 4)
      optional(:password_unusable_chars).filled(:str?, max_size?: 128)
      optional(:password_extra_dict).filled(:str?, max_size?: 4096)

      optional(:generate_password_size).filled(:int?, gteq?: 1, lteq?: 255)
      optional(:generate_password_type).filled(:str?)
      optional(:generate_password_chars).filled(:str?, format?: /^[\x20-\x7e]*$/, max_size?: 128)

      optional(:contact_name).maybe(:str?, max_size?: 255)
      optional(:contact_email).maybe(:str?, max_size?: 255)
      optional(:contact_phone).maybe(:str?, max_size?: 255)
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
