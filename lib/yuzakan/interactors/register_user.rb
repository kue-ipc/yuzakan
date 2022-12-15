require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Userレポジトリへの登録または更新
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
    @group_repository = group_repository
    @member_repository = member_repository
  end

  expose :user

  def call(params)
    username = params[:username]
    groups = params[:groups]&.map { |groupname| get_group(groupname) } || []
    data = params.slice(:username, :display_name, :email).merge({
      primary_group_id: get_group(params[:primary_group])&.id,
      deleted: false,
      deleted_at: nil,
    })
    user_id = @user_repository.find_by_username(username)&.id

    @user =
      if user_id
        @user_repository.update(user_id, data)
      else
        @user_repository.create(data)
      end
    # TODO: グループの登録
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      Hanami.logger.error "[#{self.class.name}] Validation fails: #{validation.messages}"
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
