require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class ReadGroup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
    end
  end

  expose :groupdata
  expose :groupdata_list

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @groupdata = {name: params[:groupname], attrs: {}}
    @groupdata_list = []

    providers = @provider_repository.ordered_all_with_adapter_by_operation(:group_read)
    providers.each do |provider|
      groupdata = provider.group_read(params[:groupname])
      if groupdata
        @groupdata_list << {provider: provider, groupdata: groupdata}
        @groupdata[:display_name] ||= groupdata[:display_name]
      end
    rescue => e
      Hanami.logger.error e
      error("グループ情報の読み込み時にエラーが発生しました。(#{provider.label}")
      raise if Hanami.env == 'development'
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
