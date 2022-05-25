require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class SyncGroup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
    end
  end

  def initialize(provider_repository: ProviderRepository.new, group_repository: GroupRepository.new)
    @provider_repository = provider_repository
    @group_repository = group_repository
  end

  expose :group
  expose :groupdata
  expose :groupdata_list

  def call(params)
    read_group = ReadGroup.new(provider_repository: @provider_repository)
    read_group_result = read_group.call({groupname: params[:groupname]})
    if read_group_result.failure?
      read_group_result.errors.each { |msg| error(msg) }
      fail!
    end

    @groupdata = read_group_result.groupdata
    @groupdata_list = read_group_result.groupdata_list

    error!('グループ名が一致しません。') if @groupdata[:name] != params[:groupname]

    if @groupdata_list.empty?
      unregister_group = UnregisterGroup.new(group_repository: @group_repository)
      nuregister_group_result = unregister_group.call(@groupdata.slice(:name))
      if nuregister_group_result.failure?
        nuregister_group_result.errors.each { |msg| error(msg) }
        fail!
      end

      @group = nil
    else
      register_group = RegisterGroup.new(group_repository: @group_repository)
      register_group_result = register_group.call(@groupdata.slice(:name, :display_name))
      if register_group_result.failure?
        register_group_result.errors.each { |msg| error(msg) }
        fail!
      end

      @group = register_group_result.group
    end
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
