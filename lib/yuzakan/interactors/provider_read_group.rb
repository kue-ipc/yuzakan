# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"
require_relative "../predicates/name_predicates"

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

  expose :providers

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    groupname = params[:groupname]

    @providers = get_providers(params[:providers]).to_h do |provider|
      [provider.name, provider.group_read(groupname)]
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{groupname}"
      Hanami.logger.error e
      error(I18n.t("errors.action.error", action: I18n.t("interactors.provider_read_group"), target: provider.label))
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
            error!(I18n.t("errors.not_found", name: I18n.t("entities.provider")))
          end
        end
      end
    else
      @provider_repository.ordered_all_with_adapter_by_operation(:group_read)
    end
  end
end
