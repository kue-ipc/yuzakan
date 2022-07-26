require 'hanami/interactor'
require 'hanami/validations/form'

class CreateUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
      optional(:clearance_level).filled(:int?)
      required(:primary_group).filled(:str?, :name?, max_size?: 255)
      optional(:attrs) { hash? }
    end
  end

  expose :user
  expose :password

  def initialize(provider_repository: ProviderRepository.new,
                 user_repository: UserRepository.new,
                 generate_password: GeneratePassword.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
    @generate_password = generate_password
  end

  def call(params)
    username = params[:username]

    gp_result = @generate_password.call
    error!('パスワード生成に失敗しました。') if gp_result.failure?
    @password = gp_result.password

    userdata = {
      primary_group: params[:primary_group],
      attrs: params[:attrs],
    }

    params[:providers].each do |provider_name|
      provider = @provider_repository.find_with_adapter_by_name(provider_name)
      raise 'プロバイダーが見つかりません。' unless provider

      provider.user_create(username, @password, userdata)
    rescue => e
      Hanami.logger.error e
      error!("アカウント作成時にエラーが発生しました。: #{e.message}")
    end

    sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
    result = sync_user.call({username: username})
    error!(result.errors) if result.failure?

    @user = result.user

    unless @user
      error!('ユーザーが作成されていません。')
    end

    if @user.clearance_level && @user.clearance_level != params[:clearance_level]
      @user = @user_repositary.update(@user.id, clearance_level: params[:clearance_level])
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    read_user = ReadUser.new(provider_repository: @provider_repository)
    read_user_result = read_user.call(username: params[:username])

    if read_user_result.failure?
      error(read_user_result.errors)
      return false
    end

    unless read_user_result.provider_userdatas.empty?
      error('ユーザーは既に存在します。')
      return false
    end

    true
  end
end
