class ReadUser
  include Hanami::Interactor

  expose :userdatas

  def initialize(provider_repository: ProviderRepository.new, providers: nil)
    @providers = providers || provider_repository.operational_all_with_adapter(:read).to_a
  end

  def call(params)
    @userdatas = {}
    @providers.each do |provider|
      userdata = provider.read(params[:username])
      @userdatas[provider.name] = userdata if userdata
    rescue => e
      Hanami.logger.error e
      error("ユーザー情報の読み込み時にエラーが発生しました。(#{provider.display_name}")
    end
  end
end
