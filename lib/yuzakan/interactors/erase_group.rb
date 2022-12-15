require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Groupレポジトリから抹消
class EraseGroup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
    end
  end

  expose :group

  def initialize(group_repository: GroupRepository.new)
    @group_repository = group_repository
  end

  def call(params)
    group = @group_repository.find_by_groupname(params[:groupname])
    @group_repository.delete(group.id) if group
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
end
