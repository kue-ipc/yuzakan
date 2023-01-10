require 'hanami/interactor'
require 'hanami/validations'

class CheckProvider
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:provider_id) { filled? }
    end
  end

  expose :provider

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(provider_id:)
    @provider = @provider_repository.find_with_adapter(provider_id.to_i)
    error!('該当のプロバイダーがありません。') if @provider.nil?
    # error!('チェックに失敗しました。') unless @provider.check
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
