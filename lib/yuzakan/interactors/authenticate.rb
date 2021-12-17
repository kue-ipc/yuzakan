require 'hanami/interactor'
require 'hanami/validations'

class Authenticate
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username) { filled? & str? & size?(1..255) }
      required(:password) { filled? & str? & max_size?(255) }
    end
  end

  expose :user

  def initialize(client:, app:,
                 user_repository: UserRepository.new,
                 provider_repository: ProviderRepository.new,
                 activity_repository: ActivityRepository.new)
    @client = client
    @app = app
    @user_repository = user_repository
    @provider_repository = provider_repository
    @activity_repository = activity_repository
  end

  def call(params)
    activity_params = {
      client: @client,
      type: 'user',
      target: params[:username],
      action: 'auth',
      params: {app: @app}.to_json,
    }

    failure_count = 0

    @activity_repository.user_auths(params[:username], ago: 60 * 60)
      .each do |activity|
      case activity.result
      when 'success'
        break
      when 'failure'
        failure_count += 1
      end
    end

    if failure_count >= 5
      @activity_repository.create(activity_params.merge!({result: 'reject'}))
      error!('時間あたりのログイン試行が規定の回数を超えたため、' \
             '現在ログインが禁止されています。' \
             'しばらく待ってから再度ログインを試してください。')
    end

    user_data = nil

    @provider_repository.operational_all_with_adapter(:auth).each do |provider|
      user_data = provider.auth(params[:username], params[:password])
      # 最初に認証されたところを正とする。
      break if user_data
    rescue => e
      @activity_repository.create(activity_params.merge!({result: 'error'}))
      error!("認証時にエラーが発生しました。: #{e.message}")
    end

    unless user_data
      @activity_repository.create(activity_params.merge!({result: 'failure'}))
      error!('ユーザー名またはパスワードが違います。')
    end

    @user = create_or_upadte_user(user_data)
    @activity_repository.create(activity_params.merge!({
      user_id: @user.id,
      result: 'success',
    }))
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end

  private def create_or_upadte_user(user_data)
    name = user_data[:name]
    display_name = user_data[:display_name] || user_data[:name]
    email = user_data[:email]
    user = @user_repository.by_name(name).one
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
