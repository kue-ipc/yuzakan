require 'hanami/interactor'
require 'hanami/validations'

class UserAttrs
  include Hanami::Interactor

  expose :attrs
  expose :datas

  def initialize(
    provider_attr_mapping_repository: AttrMappingRepository.new,
    readable_providers: ProviderRepository.new.operational_all_with_params(:read)
  )
    @provider_attr_mapping_repository = provider_attr_mapping_repository
    @readable_providers = readable_providers
  end

  def call(params)
    @datas = @readable_providers.each.map do |provider|
      [provider.name,
       provider.adapter.read(
         params[:username],
         @provider_attr_mapping_repository.by_provider_with_attr(provider.id)),]
    end.to_h
    @attrs = @datas.values.compact.inject({}) do |result, data|
      data.merge(result)
    end
  end
end
