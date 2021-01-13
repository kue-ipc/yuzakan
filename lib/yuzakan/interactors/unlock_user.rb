# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations/form'

class UnlockUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      optional(:username) { filled? & str? }
      optional(:password_reset) { bool? }
    end
  end

  expose :username
  expose :password
  expose :user_datas

  def initialize(
    user:,
    client:,
    config: ConfigRepostitory.new.current,
    providers: nil,
    provider_repository: ProviderRepository.new,
    activity_repository: ActivityRepository.new,
    generate_password: GeneratePassword.new,
    mailer: Mailers::UserNotify
  )
    @user = user
    @client = client
    @config = config
    @providers = providers
    @provider_repository = provider_repository
    @activity_repository = activity_repository
    @generate_password = generate_password
    @mailer = mailer
  end

  def call(params)
    @username = params&.[](:username) || @user.name

    if params&.[](:password_reset) == '1'
      gp_result = @generate_password.call
      error!('パスワード生成に失敗しました。') if gp_result.failure?
      @password = gp_result.password
    else
      @password = nil
    end

    activity_params = {
      user_id: @user.id,
      client: @client,
      type: 'user',
      target: @username,
      action: 'unlock_user',
    }

    by_user =
      if @username == @user.name
        :self
      else
        :admin
      end

    mailer_params = {
      user: @user,
      config: @config,
      by_user: by_user,
      action: 'アカウントロック解除',
      description: 'アカウントのロックを解除しました。',
    }

    if @password
      activity_params[:action] += '+reset_password'
      mailer_params[:action] += '＋パスワードリセット'
      mailer_params[:description] =
        'アカウントのロックを解除し、パスワードをリセットしました。'
      end

    if @providers
      activity_params[:action] += ':' + @providers.map(&:name).join(',')
      mailer_params[:providers] = @providers
    end

    @user_datas = {}
    result = :success

    (@providers ||
      @provider_repository.operational_all_with_params(:unlock)
    ).each do |provider|
      user_data = provider.adapter.unlock(@username, @password)
      @user_datas[provider.name] = user_data if user_data
    rescue => e
      unless @user_datas.empty?
        error <<~'ERROR_MESSAGE'
          一部のシステムについてはロックが解除されましたが、
          別のシステムでのロック解除時にエラーが発生し、処理が中断されました。
          ロックが解除されていないシステムが存在する可能性があるため、
          再度ロック解除を実行してください。
        ERROR_MESSAGE
      end
      error("アカウントロック解除時にエラーが発生しました。: #{e.message}")
      result = :error
    end

    if @user_datas.empty?
      error('どのシステムでもロックは解除は実行されませんでした。')
      result = :failure
    end

    @activity_repository.create(**activity_params, result: result.to_s)
    @mailer&.deliver(**mailer_params, result: result)
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    return ok if @user.admin

    unless @providers&.all?(&:self_management)
      error('自己管理可能なシステム以外でロックを解除することはできません。')
      ok = false
    end

    if params&.key?(:username) && params[:username] != @user.name
      error(username: '自分自身以外のアカウントのロックを解除することはできません。')
      ok = false
    end

    ok
  end
end
