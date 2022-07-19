require 'hanami/interactor'
require 'hanami/validations/form'

class CreateUserOld
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

  def initialize(
    user:,
    client:,
    providers:,
    config: ConfigRepostitory.new.current,
    activity_repository: ActivityRepository.new,
    attr_mapping_repository: AttrMappingRepository.new,
    generate_password: GeneratePassword.new,
    mailer: Mailers::UserNotify
  )
    @user = user
    @client = client
    @config = config
    @providers = providers
    @activity_repository = activity_repository
    @attr_mapping_repository = attr_mapping_repository
    @generate_password = generate_password
    @mailer = mailer
  end

  def call(params)
    @username = params&.[](:username) || @user.name
    attrs = params&.[](:attrs) || UserAttrs.new.call(username: @username).attrs

    gp_result = @generate_password.call
    error!('パスワード生成に失敗しました。') if gp_result.failure?
    @password = gp_result.password

    activity_params = {
      user_id: @user.id,
      client: @client,
      type: 'user',
      target: @username,
      action: 'create_user',
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
      action: 'アカウント作成',
      description: 'アカウントを作成しました。',
    }

    activity_params[:action] += ":#{@providers.map(&:name).join(',')}"
    mailer_params[:providers] = @providers

    @user_datas = {}
    result = :success

    @providers.each do |provider|
      # すでに作成済みの場合は何もしない
      next if provider.user_read(@username)

      user_data = provider.user_create(@username, @password, **attrs)
      @user_datas[provider.name] = user_data if user_data
    rescue => e
      Hanami.logger.error e
      unless @user_datas.empty?
        error <<~'ERROR_MESSAGE'
          一部のシステムについてはアカウントが作成されましたが、
          別のシステムでのアカウント作成時にエラーが発生し、処理が中断されました。
          作成されていないシステムが存在する可能性があるため、
          再度アカウント作成を実行してください。
        ERROR_MESSAGE
      end
      error("アカウント作成時にエラーが発生しました。: #{e.message}")
      result = :error
    end

    if @user_datas.empty?
      error('どのシステムでもアカウントは作成されませんでした。')
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

    return ok if @user.clearance_level >= 4

    unless @providers&.all?(&:self_management)
      error('自己管理可能なシステム以外でアカウントを作成することはできません。')
      ok = false
    end

    if params&.key?(:username) && params[:username] != @user.name
      error(username: '自分自身以外のアカウントの作成することはできません。')
      ok = false
    end

    if params&.key?(:attrs)
      error(attrs: '属性を指定することはできません。')
      ok = false
    end

    ok
  end
end
