class ReadUser
  include Hanami::Interactor

  expose :userdatas

  def initialize(provider_repository: ProviderRepository.new, providers: nil)
    @providers = providers || provider_repository.ordered_all_with_adapter_by_operation(:read).to_a
  end

  def call(params)
    @userdatas = []
    @providers.each do |provider|
      userdata = provider.read(params[:username])
      @userdatas << {provider: provider, userdata: userdata} if userdata
    rescue => e
      Hanami.logger.error e
      error("ユーザー情報の読み込み時にエラーが発生しました。(#{provider.label}")
    end
  end
end
