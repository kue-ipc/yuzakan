require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:display_name).filled(:str?, max_size?: 255)
      optional(:email).filled(:str?, :email?, max_size?: 255)
      optional(:clearance_level).filled(:int?)
      optional(:primary_group).filled(:str?, :name?, max_size?: 255)
      optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
      optional(:attrs) { hash? }
      optional(:reserved).maybe(:bool?)
      optional(:note).maybe(:str?, max_size?: 4096)
    end
  end

  expose :user
  expose :providers

  def initialize(provider_repository: ProviderRepository.new,
                 user_repository: UserRepository.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    username = params[:username]
    @providers = {}

    userdata = params.slice(:username, :display_name, :email, :primary_group).merge({
      attrs: params[:attrs] || {},
    })

    get_providers(params[:providers]).each do |provider|
      @providers[provider.name] = provider.user_update(username, **userdata)
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.update_user'), target: provider.label))
      error(e.message)
      fail!
    end


    sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)

    if [:clearance_level, :reserved, :note].any? { |name| params[name] }
      @user = @user_repository.update(@user.id, params.slice(:clearance_level, :reserved, :note))
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
      @provider_repository.ordered_all_with_adapter_by_operation(:user_update)
    end
  end
end
