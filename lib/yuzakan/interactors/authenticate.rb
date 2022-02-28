require 'hanami/interactor'

class Authenticate
  include Hanami::Interactor

  expose :userdatas

  def initialize(providers: nil, provider_repository: nil, find_break: true)
    @providers = providers || (provider_repository || ProviderRepository.new).operational_all_with_adapter(:auth).to_a
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
      error!("認証時にエラーが発生しました。(#{provider.label})")
    end
  end
end
