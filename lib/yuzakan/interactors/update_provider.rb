require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateProvider
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:name) { str? }
      required(:label) { str? }
      required(:adapter_name) { str? }

      optional(:readable) { bool? }
      optional(:writable) { bool? }
      optional(:authenticatable) { bool? }
      optional(:password_changeable) { bool? }
      optional(:lockable) { bool? }

      optional(:individual_password) { bool? }
      optional(:self_management) { bool? }

      optional(:params)
    end
  end

  expose :provider

  def initialize(provider: nil,
                 provider_repository: ProviderRepository.new,
                 provider_param_repository: ProviderParamRepository.new)
    @provider = provider
    @provider_repository = provider_repository
    @provider_param_repository = provider_param_repository
  end

  def call(params)
    params = params.dup
    provider_params = params.delete(:params) || {}

    @provider =
      if @provider
        @provider_repository.update(@provider.id, params)
      else
        order = @provider_repository.last_order.order + 1
        @provider_repository.create(params.merge(order: order))
      end

    @provider.adapter_param_types.each do |param_type|
      value = param_type.convert_value(provider_params[param_type.name])

      next if value.nil?

      @provider_param_repository.create_or_update(
        provider_id: @provider.id,
        name: param_type.name.to_s,
        value: param_type.dump_value(value))
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

      if params[:label] != @provider.label &&
         @provider_repository.find_by_label(params[:label])
        error({label: ['そのプロバイダー名は既に存在します。']})
        result = false
      end
    else
      # create
      if @provider_repository.find_by_name(params[:name])
        error({name: ['その識別名は既に存在します。']})
        result = false
      end

      unless ADAPTERS_MANAGER.by_name(params[:adapter_name])
        error({adapter_name: ['指定のアダプターはありません。']})
        result = false
      end

      if @provider_repository.find_by_label(params[:label])
        error({label: ['そのプロバイダー名は既に存在します。']})
        result = false
      end
    end

    result
  end
end
