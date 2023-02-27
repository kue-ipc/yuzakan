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

  def initialize(user_repository: UserRepository.new)
    @user_repository = user_repository
  end

  def call(params)
    @user = @user_repository.find_by_name(params[:username])
    return if @user.nil?
    return if @user.deleted

    @user_repository.transaction do
      @user_repository.update(@user.id, deleted: true, deleted_at: Time.now)
      @user_repository.clear_group(@user)
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
