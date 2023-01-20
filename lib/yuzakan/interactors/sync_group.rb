# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Groupレポジトリと各プロバイダーのグループ情報同期
class SyncGroup
  include Hanami::Interactor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
    end
  end

  expose :group
  expose :groupdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new,
                 group_repository: GroupRepository.new)
    @provider_repository = provider_repository
    @group_repository = group_repository
  end

  def call(params)
    groupname = params[:groupname]

    read_group_result = ReadGroup.new(provider_repository: @provider_repository)
      .call({groupname: params[:groupname]})
    if read_group_result.failure?
      Hanami.logger.error "[#{self.class.name}] Failed to call ReadGroup"
      Hanami.logger.error read_group_result.errors
      error(I18n.t('errors.action.fail', action: I18n.t('interactors.read_group')))
      read_group_result.errors.each { |msg| error(msg) }
    end

    @groupdata = read_group_result.groupdata
    @providers = read_group_result.providers

    if @providers.values.any?
      if @groupdata[:groupname] != params[:groupname]
        Hanami.logger.error "[#{self.class.name}] Do not match groupname: #{@groupdata[:groupname]}"
        error!(I18n.t('errors.eql?', left: I18n.t('attributes.group.groupname')))
      end

      register_group_result = RegisterGroup.new(group_repository: @group_repository)
        .call(@groupdata.slice(:groupname, :display_name, :primary))
      if register_group_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call RegisterGroup"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.register_group')))
        register_group_result.errors.each { |msg| error(msg) }
        fail!
      end
      @group = register_group_result.group
    else
      nuregister_group_result = UnregisterGroup.new(group_repository: @group_repository)
        .call(@groupdata.slice(:groupname))
      if nuregister_group_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call UnregisterGroup"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.unregister_group')))
        unregister_group_result.errors.each { |msg| error(msg) }
        fail!
      end
      @group = nuregister_group_result.group
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
