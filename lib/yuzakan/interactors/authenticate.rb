# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class Authenticate
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username) { filled? }
      required(:password) { filled? }
    end
  end

  expose :user

  def initialize(user_repository: UserRepository.new,
                 provider_repository: ProviderRepository.new)
    @user_repository = user_repository
    @provider_repository = provider_repository
  end

  def call(username:, **_)
    display_name = @result[:display_name] || @result[:name]
    email = @result[:email]
    @user = @user_repository.by_name(username)
    if @user
      if @user.display_name != display_name || @user.email != email
        @user = @user_repository.update(
          @user.id,
          display_name: display_name,
          email: email,
        )
      end
    else
      @user = @user_repository.create(
        name: username,
        display_name: display_name,
        email: email,
      )
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    providers = @provider_repository.operational_all_with_params(:auth)
    @result = nil
    # 最初に認証されたところを正とする。
    providers.each do |provider|
      @result = provider.adapter.auth(params[:username], params[:password])
      break if @result
    end
    unless @result && @result[:name] == params[:username]
      error('ユーザー名またはパスワードが違います。')
      return false
    end
    true
  end
end
