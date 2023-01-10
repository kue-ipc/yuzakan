require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Groupレポジトリへの登録または更新
class RegisterGroup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
      optional(:display_name).maybe(:str?, max_size?: 255)
      optional(:primary).maybe(:bool?)
    end
  end

  def initialize(group_repository: GroupRepository.new)
    @group_repository = group_repository
  end

  expose :group

  def call(params)
    groupname = params[:groupname]
    data = params(:groupname, :display_name, :primary).merge({
      deleted: false,
      deleted_at: nil,
    })
    group_id = @group_repository.find_by_groupname(groupname)&.id
    @group =
      if group_id
        @group_repository.update(group_id, data)
      else
        @group_repository.create(data)
      end
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
