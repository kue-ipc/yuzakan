# TODO: 未テスト、作りかけ

class RegisterUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:name) { filled? & str? & size?(1..255) }
      optional(:display) { filled? & str? & max_size?(255) }
      optional(:email) { filled? & str? & max_size?(255) }
    end
  end

  def initialize(user:,
                 client:,
                 user_repository: UserRepository.new,
                 activity_repository: ActivityRepository.new)
    @user = user
    @client = client
    @user_repository = user_repository
    @activity_repository = activity_repository
  end

  def call(params)
    activity_params = {
      user_id: @user.id,
      client: @client,
      type: 'user',
      target: params[:username],
      action: 'register_user',
    }

    name = user_data[:name]
    display_name = user_data[:display_name] || user_data[:name]
    email = user_data[:email]

    user = @user_repository.by_name(name).one
    @user_id =
      if user.nil?
        @user_repository.create(name: name, display_name: display_name, email: email)
      elsif user.display_name != display_name || user.email != email
        @user_repository.update(user.id, display_name: display_name, email: email)
      else
        user
      end.id
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
