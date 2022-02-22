require 'hanami/interactor'

class Authenticate
  include Hanami::Interactor

  expose :userdatas

  def initialize(provider_repository: ProviderRepository.new, providers: nil, find_break: true)
    @provider_repository = provider_repository
    @providers = providers || @provider_repository.operational_all_with_adapter(:auth)
    @find_break = find_break
  end

  def call(params)
    @userdatas = {}
    @providers.each do |provider|
      userdata = provider.auth(params[:username], params[:password])
      if userdata
        @userdatas[provider.name] = userdata
        break if @find_break
      end
    rescue => e
      Hanami.logger.error e
      error!("認証時にエラーが発生しました。(#{provider.display_name})")
    end
  end
end
