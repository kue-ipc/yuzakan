# frozen_string_literal: true

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
