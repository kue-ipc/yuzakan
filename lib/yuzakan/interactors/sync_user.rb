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
  expose :userdata
  expose :userdata_list

  def call(params)
    read_user = ReadUser.new(provider_repository: @provider_repository)
    read_user_result = read_user.call({username: params[:username]})
    if read_user_result.failure?
      read_user_result.errors.each { |msg| error(msg) }
      fail!
    end

    @userdata = read_user_result.userdata
    @userdata_list = read_user_result.userdata_list

    if @userdata[:name] != params[:username]
      error!('ユーザー名が一致しません。')
    end

    if !@userdata_list.empty?
      register_user = RegisterUser.new(user_repository: @user_repository)
      register_user_result = register_user.call(@userdata.slice(:name, :display_name, :email))
      if register_user_result.failure?
        register_user_result.errors.each { |msg| error(msg) }
        fail!
      end

      @user = register_user_result.user
    else
      unregister_user = UnregisterUser.new(user_repository: @user_repository)
      nuregister_user_result = unregister_user.call(@userdata.slice(:name))
      if nuregister_user_result.failure?
        nuregister_user_result.errors.each { |msg| error(msg) }
        fail!
      end

      @user = nil
    end
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