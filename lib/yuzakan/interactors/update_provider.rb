# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateProvider
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:name) { str? }
      required(:display_name) { str? }
      required(:adapter_name) { str? }

      optional(:readable) { bool? }
      optional(:writable) { bool? }
      optional(:authenticatable) { bool? }
      optional(:password_changeable) { bool? }
      optional(:lockable) { bool? }

      optional(:params)
    end
  end

  expose :provider

  def initialize(provider: nil, provider_repository: ProviderRepository.new)
    @provider = provider
    @provider_repository = provider_repository
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

    adapter_class = @provider.adapter_class

    @param_repos = {
      boolean: ProviderBooleanParamRepository.new,
      string: ProviderStringParamRepository.new,
      text: ProviderTextParamRepository.new,
      integer: ProviderIntegerParamRepository.new,
      float: ProviderFloatParamRepository.new,
      datetime: ProviderDatetimeParamRepository.new,
      date: ProviderDateParamRepository.new,
      time: ProviderTimeParamRepository.new,
      file: ProviderFileParamRepository.new,
    }

    adapter_class.params.each do |adapter_param|
      name = adapter_param[:name]
      @param_repos[adapter_param[:type]].create_or_update(
        provider_id: @provider.id,
        name: name,
        value: provider_params[name.intern],
        encrypted: adapter_param[:encrypted])
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
