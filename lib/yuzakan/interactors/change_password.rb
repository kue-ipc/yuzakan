require 'hanami/interactor'

class ChangePassword
  include Hanami::Interactor

  expose :userdata_list

  def initialize(provider_repository: ProviderRepository.new, providers: nil)
    @providers = providers || provider_repository.ordered_all_with_adapter_by_operation(:user_change_password).to_a
  end

  def call(params)
    @userdata_list = {}
    @providers.each do |provider|
      userdata = provider.user_change_password(params[:username], params[:password])
      @userdata_list[provider.name] = userdata if userdata
    rescue => e
      Hanami.logger.error e
      error("パスワード変更時にエラーが発生しました。(#{provider.label})")
      unless @userdata_list.empty?
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
