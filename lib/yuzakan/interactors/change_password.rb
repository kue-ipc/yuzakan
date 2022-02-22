require 'hanami/interactor'

class ChangePassword
  include Hanami::Interactor

  expose :userdatas

  def initialize(provider_repository: ProviderRepository.new, providers: nil)
    @provider_repository = provider_repository
    @providers = providers || @provider_repository.operational_all_with_adapter(:change_password)
  end

  def call(params)
    @userdatas = {}
    @providers.each do |provider|
      userdata = provider.change_password(params[:username], params[:password])
      @userdatas[provider.name] = userdata if userdata
    rescue => e
      Hanami.logger.error e
      error("パスワード変更時にエラーが発生しました。(#{provider.display_name})")
      unless @userdatas.empty?
        error <<~'ERROR_MESSAGE'
          一部のシステムのパスワードは変更されましたが、
          別のシステムの変更時にエラーが発生し、処理が中断されました。
          変更されていないシステムが存在する可能性があるため、
          再度パスワードを変更してください。
          現在のパスワードはすでに変更されている場合があります。
        ERROR_MESSAGE
      end
    end
  end
end
