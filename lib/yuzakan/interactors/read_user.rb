# TODO: 未テスト、作りかけ

class ReadUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username) { filled? & str? & size?(1..255) }
    end
  end

  def initialize(user:, client:,
                 user_repository: UserRepository.new,
                 provider_repository: ProviderRepository.new,
                 activity_repository: ActivityRepository.new)
    @user = user
    @client = client
    @user_repository = user_repository
    @provider_repository = provider_repository
    @activity_repository = activity_repository
  end

  def call(params)
    activity_params = {
      user_id: @user.id,
      client: @client,
      type: 'user',
      target: params[:username],
      action: 'read_user',
    }

    user_data = nil

    @provider_repository.operational_all_with_adapter(:read).each do |provider|
      user_data = provider.read(params[:username])
      # 最初に読み込みされたところを正とする。
      break if user_data
    rescue => e
      @activity_repository.create(**activity_params, result: 'error')
      error!("ユーザー情報の読み込み時にエラーが発生しました。: #{e.message}")
    end

    unless user_data
      @activity_repository.create(**activity_params, result: 'failure')
      error!('該当のユーザーが見つかりません。')
    end

    register_user = RegisterUser.new(user: @user, client: @client,
                                     user_repository: @user_repository,
                                     activity_repository: @activity_repository)
    create_or_upadte_user(user_data)
    register_user.call(user_data)
    @activity_repository.create(**activity_params, result: 'success')
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end
end
