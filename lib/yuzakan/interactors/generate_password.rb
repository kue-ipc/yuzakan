# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class GeneratePassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      optional(:size).maybe(:int?, gteq?: 1, lteq?: 255)
      optional(:type).maybe(:str?, max_size?: 255)
      optional(:chars).maybe(:str?, max_size?: 255)
    end
  end

  expose :password

  def initialize(config_repository: ConfigRepository.new)
    @config_repository = config_repository
  end

  def call(params)
    current_config = @config_repository.current
    size = params[:size] || current_config.generate_password_size
    type = params[:type] || current_config.generate_password_type
    chars = params[:chars] || current_config.generate_password_chars

    char_list =
      case type.intern
      when :alphanumeric
        ['0'..'9', 'A'..'Z', 'a'..'z'].flat_map(&:to_a) - chars.chars
      when :ascii
        ("\x20".."\x7e").to_a - chars.chars
      when :custom
        chars.chars
      else
        []
      end.uniq

    @password = size.times.map do
      char_list[SecureRandom.random_number(char_list.size)]
    end.join
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
