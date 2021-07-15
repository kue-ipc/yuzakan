require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateAttr
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:name) { filled? & str? }
      required(:display_name) { str? }
      required(:type) { str? }

      optional(:order) { gt? 0 }
      optional(:hidden) { bool? }

      optional(:attr_mappings) { array? }
    end
  end

  expose :attr

  def initialize(attr: nil,
                 attr_repository: AttrRepository.new,
                 attr_mapping_repository: AttrMappingRepository.new)
    @attr = attr
    @attr_repository = attr_repository
    @attr_mapping_repository = attr_mapping_repository
  end

  def call(params)
    params = params.dup
    params_attr_mappings = params.delete(:attr_mappings) || []

    @attr =
      if @attr
        @attr_repository.update(@attr.id, params)
      else
        unless params[:order]
          params[:order] = @attr_repository.last_order&.order.to_i + 1
        end
        @attr_repository.create(params)
      end

    params_attr_mappings.each do |attr_mapping_params|
      attr_mapping = @attr_mapping_repository.find_by_provider_attr(
        attr_mapping_params[:provider_id], @attr.id)

      if attr_mapping_params[:name].nil? || attr_mapping_params[:name].empty?
        @attr_mapping_repository.delete(attr_mapping.id) if attr_mapping
        next
      end

      if attr_mapping_params[:conversion].nil? ||
         attr_mapping_params[:conversion].empty?
        attr_mapping_params[:conversion] = nil
      end

      if attr_mapping
        @attr_mapping_repository.update(attr_mapping.id, mapping_params)
      else
        @attr_mapping_repository.create(attr_id: attr.id, **mapping_params)
      end

      @attr_mapping_repository.create(attr_id: attr.id, **attr_mapping_params)
    end




    adapter_class = @provider.adapter_class

    @param_repos = {
      boolean: ProviderBooleanParamRepository.new,
      string: ProviderStringParamRepository.new,
      text: ProviderTextParamRepository.new,
      integer: ProviderIntegerParamRepository.new,
    }

    provider_params = adapter_class.encrypt(provider_params)

    adapter_class.params.each do |adapter_param|
      name = adapter_param[:name]
      value = provider_params[name.intern]

      value = nil if adapter_param[:encrypted] && value && value.empty?

      next if value.nil?

      @param_repos[adapter_param[:type]].create_or_update(
        provider_id: @provider.id,
        name: name,
        value: value)
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    result = true

    if @provider
      # update
      if params[:name] != @provider.name
        error({name: ['識別名は変更できません。']})
        result = false
      end

      if params[:adapter_name] != @provider.adapter_name
        error({adapter_name: ['アダプターは変更できません。']})
        result = false
      end

      if params[:display_name] != @provider.display_name &&
         @provider_repository.find_by_display_name(params[:display_name])
        error({display_name: ['そのプロバイダー名は既に存在します。']})
        result = false
      end
    else
      # create
      if @provider_repository.find_by_name(params[:name])
        error({name: ['その識別名は既に存在します。']})
        result = false
      end

      unless ADAPTERS.by_name(params[:adapter_name])
        error({adapter_name: ['指定のアダプターはありません。']})
        result = false
      end

      if @provider_repository.find_by_display_name(params[:display_name])
        error({display_name: ['そのプロバイダー名は既に存在します。']})
        result = false
      end
    end

    result
  end
end
