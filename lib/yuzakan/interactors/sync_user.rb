require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class SyncUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
    end
  end

  def initialize(provider_repository: ProviderRepository.new, user_repository: UserRepository.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  expose :user

  def call(params)
    read_user = ReadUser.new(provider_repository: @provider_repository)
    read_user_result = read_user.call({username: params[:username]})
    if read_user_result.failure?
      read_user_result.errors.each { |msg| error(msg) }
      fail!
    end

    register_user = RegisterUser.new(user_repository: @user_repository)
    register_user_result = register_user.call(read_user_result.userdata.slice(:name, :display_name, :email))

    if register_user_result.failure?
      register_user_result.errors.each { |msg| error(msg) }
      fail!
    end

    @user = register_user_result.user
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
