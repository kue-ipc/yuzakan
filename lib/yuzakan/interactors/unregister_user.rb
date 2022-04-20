require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class UnregisterUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:name).filled(:str?, :name?, max_size?: 255)
    end
  end

  def initialize(user_repository: UserRepository.new)
    @user_repository = user_repository
  end

  def call(params)
    user = @user_repository.find_by_name(params[:name])
    @user_repository.delete(user.id) if user
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
