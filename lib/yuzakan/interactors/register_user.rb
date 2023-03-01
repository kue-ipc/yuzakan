# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Userレポジトリへの登録または更新
class RegisterUser
  include Hanami::Interactor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:display_name).maybe(:str?, max_size?: 255)
      optional(:email).maybe(:str?, :email?, max_size?: 255)
      optional(:primary_group).maybe(:str?, :name?, max_size?: 255)
      optional(:groups).each(:str?, :name?, max_size?: 255)
    end
  end

  expose :user

  def initialize(user_repository: UserRepository.new,
                 group_repository: GroupRepository.new,
                 member_repository: MemberRepository.new)
    @user_repository = user_repository
    @group_repository = group_repository
    @member_repository = member_repository
  end

  def call(params)
    username = params[:username]
    data = {
      name: params[:username],
      **params.slice(:display_name, :email),
      deleted: false,
      deleted_at: nil,
    }
    user_id = @user_repository.find_by_name(username)&.id

    @user_repository.transaction do
      @user =
        if user_id
          @user_repository.update(user_id, data)
        else
          @user_repository.create(data)
        end

      @member_repository.set_primary_group_for_user(@user, get_group(params[:primary_group])) if params[:primary_group]

      if params[:groups]
        groups = [params[:primary_group], *params[:groups]].compact.uniq.map { |groupname| get_group(groupname) }
        @member_repository.set_groups_for_user(@user, groups)
      end
    end

    @user = @user_repository.find_with_groups(@user.id)
  end

  private def valid?(params)
    result = Validator.new(params).validate
    if result.failure?
      Hanami.logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
      error(result.messages)
      return false
    end

    true
  end

  private def get_group(groupname)
    return unless groupname

    @groups ||= {}
    @groups[groupname] ||= @group_repository.find_or_create_by_name(groupname)
  end
end
