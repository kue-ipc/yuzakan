require 'hanami/interactor'
require 'hanami/validations'

class Authenticate
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username) { filled? & str? & max_size?(255) }
      required(:password) { filled? & str? & max_size?(255) }
      required(:client).filled?(:str?)
      required(:uuid).filled?(:str?)
    end
  end

  expose :user

  def initialize(user_repository: UserRepository.new,
                 provider_repository: ProviderRepository.new,
                 auth_log_repository: AuthLogRepository.new)
    @user_repository = user_repository
    @provider_repository = provider_repository
    @auth_log_repository = auth_log_repository
  end

  def call(params)
    auth_log_params = {
      uuid: params[:uuid],
      client: params[:client],
      username: params[:username],
    }

    failure_count = 0

    # 10 minutes
    @auth_log_repository.recent_by_username(params[:username], 600).each do |auth_log|
      case auth_log.result
      when 'success', 'recover'
        break
      when 'failure'
        failure_count += 1
      end
    end

    if failure_count >= 5
      @auth_log_repository.create(**auth_log_params, result: 'reject')
      error!('時間あたりのログイン試行が規定の回数を超えたため、' \
             '現在ログインが禁止されています。' \
             'しばらく待ってから再度ログインを試してください。')
    end

    userdata = nil

    @provider_repository.operational_all_with_adapter(:auth).each do |provider|
      if provider.auth(params[:username], params[:password])
        # 最初に認証されたところを正とする。
        userdata = provider.read(params[:username])
        break
      end
    rescue => e
      Hanami.logger.error e
      @auth_log_repository.create(**auth_log_params, result: 'error')
      error!("認証時にエラーが発生しました。: #{e.message}")
    end

    unless userdata
      @auth_log_repository.create(**auth_log_params, result: 'failure')
      error!('ユーザー名またはパスワードが違います。')
    end

    @user = create_or_upadte_user(userdata)
    @auth_log_repository.create(**auth_log_params, result: 'success')
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end

  private def create_or_upadte_user(userdata)
    name = userdata[:name]
    display_name = userdata[:display_name] || userdata[:name]
    email = userdata[:email]
    user = @user_repository.find_by_name(name)
    if user.nil?
      @user_repository.create(name: name,
                              display_name: display_name,
                              email: email)
    elsif user.display_name != display_name || user.email != email
      @user_repository.update(user.id,
                              display_name: display_name,
                              email: email)
    else
      user
    end
  end
end
