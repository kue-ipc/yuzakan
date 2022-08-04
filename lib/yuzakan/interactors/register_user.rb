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
      optional(:display_name).filled(:str?, max_size?: 255)
      optional(:email).filled(:str?, :email?, max_size?: 255)
      optional(:primary_group).filled(:str?, :name?, max_size?: 255)
      optional(:groups).each(:str?, :name?, max_size?: 255)
    end
  end

  def initialize(user_repository: UserRepository.new,
                 group_repository: GroupRepository.new,
                 member_repository: MemberRepository.new)
    @user_repository = user_repository
    @gorup_repository = group_repository
    @member_repository = member_repository
  end

  expose :user

  def call(params)
    username = params[:username]
    display_name = params[:display_name] || params[:username]
    email = params[:email]

    primary_group = get_group(params[:primary_group])
    groups = params[:groups]&.map { |groupname| get_group(groupname) } || []

    data = {username: username, display_name: display_name, email: email, primary_group_id: primary_group&.id}
    user_id = @user_repository.find_by_username(username)&.id
    @user =
      if user_id
        @user_repository.update(user_id, data)
      else
        @user_repository.create(data)
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

  private def get_group(groupname)
    return if groupname.nil?

    @groups ||= {}
    @groups[groupname] ||= @group_repository.find_or_create_by_groupname(groupname)
  end
end
