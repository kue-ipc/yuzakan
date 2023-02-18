# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Userレポジトリからの解除
class UnregisterUser
  include Hanami::Interactor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
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
    @user = @user_repository.find_by_name(params[:username])
    if @user
      @user_repository.update(@user.id,
                              deleted: true,
                              deleted_at: Time.now)
    end
    @user_repository.set_primary_group(@user, nil)
    current_groups = @user_repository.find_with_groups(@user.id).groups
    current_groups.groups.each do |current_group|
      @user_repository.remove_group(user, group) if groups.none? { |group| group.groupname == current_group.groupname }
    end
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
end
