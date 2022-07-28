require 'hanami/interactor'
require 'hanami/validations'

class Authenticate
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      required(:password).maybe(:str?, max_size?: 255)
    end
  end

  expose :provider

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    providers = @provider_repository.ordered_all_with_adapter_by_operation(:user_auth)

    @provider = nil
    providers.each do |provider|
      if provider.user_auth(params[:username], params[:password])
        @provider = provider
        break
      end
    rescue => e
      Hanami.logger.error e
      error!("認証処理でエラーが発生しました。(#{provider.label})")
    end
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
