require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class RegisterGroup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
      optional(:display_name).maybe(:str?, max_size?: 255)
    end
  end

  def initialize(group_repository: GroupRepository.new)
    @group_repository = group_repository
  end

  expose :group

  def call(params)
    groupname = params[:groupname]
    display_name = params[:display_name] || params[:groupname]

    group = @group_repository.find_by_groupname(groupname)
    @group =
      if group.nil?
        @group_repository.create(groupname: groupname, display_name: display_name)
      elsif group.display_name != display_name
        @group_repository.update(group.id, display_name: display_name)
      else
        group
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
