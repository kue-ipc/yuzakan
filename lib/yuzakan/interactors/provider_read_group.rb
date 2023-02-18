# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

class ProviderReadGroup
  include Hanami::Interactor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:groupname).filled(:str?, :name?, max_size?: 255)
      optional(:providers).each(:str?, :name?, max_size?: 255)
    end
  end

  expose :groupdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @groupdata = {primary: false}
    @providers = {}

    get_providers(params[:providers]).each do |provider|
      groupdata = provider.group_read(params[:groupname])
      @providers[provider.name] = groupdata
      if groupdata
        %i[groupname display_name].each do |name|
          @groupdata[name] ||= groupdata[name] unless groupdata[name].nil?
        end
        @groupdata[:primary] = true if groupdata[:primary]
      end
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{params[:groupname]}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.read_group'), target: provider.label))
      error(e.message)
      fail!
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

  private def get_providers(providers = nil)
    if providers
      providers.map do |provider_name|
        @provider_repository.find_with_adapter_by_name(provider_name).tap do |provider|
          unless provider
            Hanami.logger.warn "[#{self.class.name}] Not found: #{provider_name}"
            error!(I18n.t('errors.not_found', name: I18n.t('entities.provider')))
          end
        end
      end
    else
      @provider_repository.ordered_all_with_adapter_by_operation(:group_read)
    end
  end
end
