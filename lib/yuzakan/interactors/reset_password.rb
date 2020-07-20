# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations/form'

class ResetPassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      optional(:username) { filled? & str? }
    end
  end

  expose :username
  expose :password
  expose :user_datas
  expose :count

  def initialize(
    user:,
    client:,
    config: ConfigRepostitory.new.current,
    providers: ProviderRepository.new
      .operational_all_with_params(:change_password),
    activity_repository: ActivityRepository.new,
    generate_password: GeneratePassword.new,
    mailer: Mailers::ResetPassword
  )
    @user = user
    @client = client
    @config = config
    @providers = providers
    @activity_repository = activity_repository
    @generate_password = generate_password
    @mailer = mailer
  end

  def call(params)
    username = params&.get(:username) || @user.name

    activity_params = {
      user: @user,
      client: @client,
      type: 'user',
      target: username,
      action: 'reset_password: ' + @providers.map(&:name).join(','),
    }

    result = @generate_password.call

    error!('パスワード生成に失敗しました。') if result.failure?

    @password = result.password

    @count = 0
    @user_datas = {}

    by_user =
      if username == @user.name
        :self
      else
        :admin
      end

    @providers.each do |provider|
      user_data = provider.adapter.change_password(username, @password)
      if user_data
        @user_datas[provider.name] = user_data
        @count += 1
      end
    rescue => e
      @activity_repository.create(activity_params.merge!({result: 'error'}))
      @mailer&.deliver(user: @user, config: @config, by_user: by_user,
                       result: :error)
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
      @activity_repository.create(activity_params.merge!({result: 'failure'}))
      @mailer&.deliver(user: @user, config: @config, by_user: by_user,
                       result: :failure)
      error!('どのシステムでもパスワードはリセットされませんでした。')
    end

    @activity_repository.create(activity_params.merge!({result: 'success'}))
    @mailer&.deliver(user: @user, config: @config, by_user: by_user,
                     result: :success)
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    return ok if @user.admin

    unless @providers.all?(&:self_management)
      error('自己管理可能なシステム以外でパスワードをリセットすることはできません。')
      ok = false
    end

    if params&.get(:username) && params&.get(:username) != @user.name
      error(username: '自分自身以外のアカウントのパスワードをリセットすることはできません。')
      ok = false
    end

    ok
  end
end
