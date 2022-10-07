require 'hanami/interactor'
require 'hanami/validations'

class ReadUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:providers).each(:str?, :name?, max_size?: 255)
    end
  end

  expose :username
  expose :userdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(params)
    @username = params[:username]
    @userdata = {attrs: {}, groups: []}
    @providers = {}

    get_providers(params[:providers]).each do |provider|
      userdata = provider.user_read(params[:username])
      @providers[provider.name] = userdata
      if userdata
        %i[username display_name email locked unmanageable mfa].each do |name|
          @userdata[name] ||= userdata[name] unless userdata[name].nil?
        end
        @userdata[:primary_group] ||= userdata[:primary_group] unless userdata[:primary_group].nil?
        @userdata[:groups] |= userdata[:groups] unless userdata[:groups].nil?
        @userdata[:attrs] = userdata[:attrs].merge(@userdata[:attrs]) unless userdata[:attrs].nil?
      end
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{@username}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.read_user'), target: provider.label))
      error(e.message)
      fail!
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      Hanami.logger.error "[#{self.class.name}] Validation fails: #{validation.messages}"
      error(validation.messages)
      return false
    end

    true
  end

  private def get_providers(providers = nil)
    if providers
      providers.map do |provider_name|
        provider = @provider_repository.find_with_adapter_by_name(provider_name)
        unless provider
          Hanami.logger.warn "[#{self.class.name}] Not found: #{provider_name}"
          error!(I18n.t('errors.not_found', name: I18n.t('entities.provider')))
        end

        provider
      end
    else
      @provider_repository.ordered_all_with_adapter_by_operation(:user_read)
    end
  end
end
