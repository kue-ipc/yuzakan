require 'hanami/interactor'

class Authenticate
  include Hanami::Interactor

  expose :provider

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    providers = @provider_repository.ordered_all_with_adapter_by_operation(:auth)

    @provider = nil
    providers.each do |provider|
      result = provider.auth(params[:username], params[:password])
      if result
        @provider = provider
        break
      end
    rescue => e
      Hanami.logger.error e
      error!("認証処理でエラーが発生しました。(#{provider.label})")
    end
  end
end
