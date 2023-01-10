# frozen_string_literal: true

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
    data = params.slice(:username, :display_name, :email).merge({
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

    @user_repository.set_primary_group(@user, get_group(params[:primary_group])) if params.key?(:primary_group)

    if params[:groups]
      current_groups = @user_repository.find_with_groups(@user.id).groups
      groups = params[:groups].map { |groupname| get_group(groupname) }

      groups.each do |group|
        if current_groups.none? { |current_group| current_group.gorupname == group.groupname }
          @user_repository.add_group(@user, group)
        end
      end
      current_groups.each do |current_group|
        if groups.none? { |group| group.groupname == current_group.groupname }
          @user_repository.remove_group(user, group)
        end
      end
    end

    @user = @user_repository.find_with_groups(@user.id)
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
    return unless groupname

    @groups ||= {}
    @groups[groupname] ||= @group_repository.find_or_create_by_groupname(groupname)
  end
end
