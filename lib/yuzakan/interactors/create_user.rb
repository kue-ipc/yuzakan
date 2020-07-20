# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations/form'

class CreateUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      optional(:username) { filled? & str? }
      optional(:attrs) { hash? }
    end
  end

  expose :username
  expose :password
  expose :user_datas

  def initialize(user:,
                 client:,
                 config: ConfigRepostitory.new.current,
                 providers:,
                 activity_repository: ActivityRepository.new,
                 generate_password: GeneratePassword.new,
                 mailer: Mailers::CreateUser)
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
    attrs = params&.get(:attrs) ||
            UserAttrs.new.call(username: current_user.name).attrs

    activity_params = {
      user: @user,
      client: @client,
      type: 'user',
      target: username,
      action: 'create_user: ' + @providers.map(&:name).join(','),
    }

    @count = 0

    result = @generate_password.call

    error!('パスワード生成に失敗しました。') if result.failure?

    @password = result.password
    @user_datas = {}

    user_by =
      if username == @user.name
        :self
      else
        :admin
      end

    @providers.each do |provider|
      user_data = provider.read(username)
      if user_data
        @user_datas[provider.name] = user_data
        error("#{provider.display_name}にアカウントは作成済みです。")
        next
      end

      user_data = provider.adapter.create(
        username,
        attrs,
        AttrMappingRepository.new
          .by_provider_with_attr(provider.id),
        @password)

      @user_datas[provider.name] = user_data
      @count += 1
    rescue => e
      @activity_repository.create(activity_params.merge!({result: 'error'}))
      @mailer&.deliver(user: @user, config: @config, user_by: user_by,
                       result: :error)
      if @count.positive?
        error <<~'ERROR_MESSAGE'
          一部のシステムについてはアカウントが作成されましたが、
          別のシステムでのアカウント作成時にエラーが発生し、処理が中断されました。
          作成されていないシステムが存在する可能性があるため、
          再度アカウント作成を実行してください。
        ERROR_MESSAGE
      end
      error!("アカウント作成時にエラーが発生しました。: #{e.message}")
    end

    if @count.zero?
      @activity_repository.create(activity_params.merge!({result: 'failure'}))
      @mailer&.deliver(user: @user, config: @config, user_by: user_by,
                       result: :failure)
      error!('どのシステムでもアカウントは作成されませんでした。')
    end

    @activity_repository.create(activity_params.merge!({result: 'success'}))
    @mailer&.deliver(user: @user, config: @config, user_by: user_by,
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
      error('自己管理可能なシステム以外でアカウントを作成することはできません。')
      ok = false
    end

    if params[:username] && params[:username] != @user.name
      error(username: '自分自身以外のアカウントを作成することはできません。')
      ok = false
    end

    if params[:attrs]
      error(attrs: '属性を指定することはできません。')
      ok = false
    end

    ok
  end
end
