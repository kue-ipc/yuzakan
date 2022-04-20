class ReadUser
  include Hanami::Interactor

  expose :userdata
  expose :userdatas

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @userdata = {}
    @userdatas = []

    providers = @provider_repository.ordered_all_with_adapter_by_operation(:read)
    providers.each do |provider|
      userdata = provider.read(params[:username])
      @userdatas << {provider: provider, userdata: userdata} if userdata
      @userdata = userdata.merge(@userdata)
    rescue => e
      Hanami.logger.error e
      error("ユーザー情報の読み込み時にエラーが発生しました。(#{provider.label}")
    end
  end
end
