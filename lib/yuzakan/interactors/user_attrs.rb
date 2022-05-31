require 'hanami/interactor'
require 'hanami/validations'

class UserAttrs
  include Hanami::Interactor

  expose :attrs
  expose :providers_attrs

  def initialize(
    provider_attr_mapping_repository: AttrMappingRepository.new,
    readable_providers: ProviderRepository.new.ordered_all_with_adapter_by_operation(:read)
  )
    @provider_attr_mapping_repository = provider_attr_mapping_repository
    @readable_providers = readable_providers
  end

  def call(params)
    @providers_attrs = @readable_providers.each.map do |provider|
      provider.user_read(params[:username])&.[](:attrs)
    end
    # 最初の方を優先する。
    @attrs = @providers_attrs.compact.inject({}) do |result, data|
      data.merge(result)
    end
  end
end
