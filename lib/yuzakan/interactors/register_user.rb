# Userレポジトリへの登録または更新

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class RegisterUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:display_name).maybe(:str?, max_size?: 255)
      optional(:email).maybe(:str?, :email?, max_size?: 255)
    end
  end

  def initialize(user_repository: UserRepository.new)
    @user_repository = user_repository
  end

  expose :user

  def call(params)
    username = params[:username]
    display_name = params[:display_name] || params[:username]
    email = params[:email]

    user = @user_repository.find_by_username(username)
    @user =
      if user.nil?
        @user_repository.create(username: username, display_name: display_name, email: email)
      elsif user.display_name != display_name || user.email != email
        @user_repository.update(user.id, display_name: display_name, email: email)
      else
        user
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
