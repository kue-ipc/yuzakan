require 'hanami/interactor'
require 'hanami/validations/form'

class ResetPassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
    end
  end

  expose :username
  expose :password
  expose :count

  def initialize(
    provider_repository: ProviderRepository.new,
    generate_password: GeneratePassword.new
  )
    @provider_repository = provider_repository
    @generate_password = generate_password
  end

  def call(params)
    @username = params[:username]

    gp_result = @generate_password.call
    error!(I18n.t('errors.action.failed', action: I18n.t('interactors.generate_password'))) if gp_result.failure?
    @password = gp_result.password

    @count = 0

    providers =
      if params[:providers]
        params[:providers].map do |provider_name|
          provider = @provider_repository.find_with_adapter_by_name(provider_name)
          unless provider
            Hanami.logger.warn "Not found: #{provider_name}"
            error!(I18n.t('errors.not_found', name: I18n.t('entities.provider')))
          end

          provider
        end
      else
        @provider_repository.ordered_all_with_adapter_by_operation(:user_change_password)
      end

    providers.each do |provider|
      @count += 1 if provider.user_change_password(@username, @password)
    rescue => e
      Hanami.logger.error "Failed to restet_password on #{provider.name}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.reset_password'), target: provider.label))
      if @count.positive?
        error(I18n.t('errors.action.stopped_after_some',
                     action: I18n.t('interactors.reset_password'),
                     target: I18n.t('entities.provider')))
      end
      error!(e.message)
    end

    if @count.zero?
      Hanami.logger.warn "No provider reset_password"
      error!(I18n.t('errors.action.not_run',
                    action: I18n.t('interactors.reset_password'),
                    target: I18n.t('entities.provider')))
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      false
    end

    true
  end

  private def generate_password
    gp_result = @generate_password.call
    error!(I18n.t('errors.action.failed', action: I18n.t('interactors.generate_password'))) if gp_result.failure?
    gp_result.password
  end
end
