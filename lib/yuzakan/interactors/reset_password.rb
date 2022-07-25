require 'hanami/interactor'
require 'hanami/validations/form'

class ResetPassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      required(:providers) { array? { each { str? & name? & max_size?(255) } } }
    end
  end

  expose :username
  expose :password
  expose :count

  def initialize(
    provider_repository: ProviderRepository.new,
    generate_password: GeneratePassword.new)
    @provider_repository = provider_repository
    @generate_password = generate_password
  end

  def call(params)
    @username = params[:username]

    gp_result = @generate_password.call
    error!('パスワード生成に失敗しました。') if gp_result.failure?
    @password = gp_result.password

    @count = 0

    params[:providers].each do |provider_name|
      provider = @provider_repository.find_with_adapter_by_name(provider_name)
      raise 'プロバイダーが見つかりません。' unless provider

      @count += 1 if provider.user_change_password(@username, @password)
    rescue => e
      Hanami.logger.error e
      if @count.positive?
        error <<~'ERROR_MESSAGE'
          一部のシステムについてはパスワードがリセットされましたが、
          別のシステムでのパスワードリセット時にエラーが発生し、処理が中断されました。
          リセットされていないシステムが存在する可能性があるため、
          再度パスワードリセットを実行してください。
        ERROR_MESSAGE
      end
      error!("パスワードリセット時にエラーが発生しました。: #{e.message}")
    end

    if @count.zero?
      error!('どのシステムでもパスワードはリセットされませんでした。')
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end
  end
end
