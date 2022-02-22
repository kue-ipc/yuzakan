# 自分自身のパスワードのみ変更可能
# パスワードの制限値はconifgで管理
# 強度チェックはzxcvbnを使用

require 'hanami/interactor'
require 'hanami/validations/form'
require 'zxcvbn'

class ChangePassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:username).filled
      required(:password).filled
    end
  end

  expose :count

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    username = params[:username]
    password = params[:password]

    @count = 0

    @provider_repository.operational_all_with_adapter(:change_password).each do |provider|
      count += 1 if provider.change_password(username, password)
    rescue => e
      Hanami.logger.error e
      unless count.zero?
        error <<~'ERROR_MESSAGE'
          一部のシステムのパスワードは変更されましたが、
          別のシステムの変更時にエラーが発生し、処理が中断されました。
          変更されていないシステムが存在する可能性があるため、
          再度パスワードを変更してください。
          現在のパスワードはすでに変更されている場合があります。
        ERROR_MESSAGE
      end
      error!("パスワード変更時にエラーが発生しました。: #{e.message}")
    end

    error!('どのシステムでもパスワードは変更されませんでした。') if count.zero?
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    ok
  end
end
