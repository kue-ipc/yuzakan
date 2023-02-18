# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class ProviderReadUser
  include Hanami::Interactor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:providers).each(:str?, :name?, max_size?: 255)
    end
  end

  expose :userdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    username = params[:username]

    @userdata = {attrs: {}, groups: []}
    @providers = {}

    get_providers(params[:providers]).each do |provider|
      userdata = provider.user_read(username)
      @providers[provider.name] = userdata
      if userdata
        %i[username display_name email primary_group].each do |name|
          @userdata[name] ||= userdata[name] unless userdata[name].nil?
        end
        @userdata[:groups] |= userdata[:groups] unless userdata[:groups].nil?
        @userdata[:attrs] = userdata[:attrs].merge(@userdata[:attrs]) unless userdata[:attrs].nil?
      end
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.read_user'), target: provider.label))
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

  private def get_providers(provider_names = nil)
    operation = :user_read
    if provider_names
      provider_names.map do |provider_name|
        provider = @provider_repository.find_with_adapter_by_name(provider_name)
        unless provider
          Hanami.logger.warn "[#{self.class.name}] Not found: #{provider_name}"
          error!(I18n.t('errors.not_found', name: I18n.t('entities.provider')))
        end

        unless provider.can_do?(:user_change_password)
          Hanami.logger.warn "[#{self.class.name}] No ability: #{provider.name}, #{operation}"
          error!(I18n.t('errors.no_ability', name: provider.label, action: I18n.t(operation, scope: 'operations')))
        end

        provider
      end
    else
      @provider_repository.ordered_all_with_adapter_by_operation(operation)
    end
  end
end
