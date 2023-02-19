# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Groupレポジトリへの登録または更新
class RegisterGroup
  include Hanami::Interactor

  class Validator
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
    data = {
      name: params[:groupname],
      **params.slice(:display_name, :primary),
      deleted: false,
      deleted_at: nil,
    }
    group_id = @group_repository.find_by_name(params[:groupname])&.id
    @group =
      if group_id
        @group_repository.update(group_id, data)
      else
        @group_repository.create(data)
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
