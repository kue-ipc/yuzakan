require 'hanami/interactor'
require 'hanami/validations/form'

class CreateAttr
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    predicates NamePredicates
    messages :i18n

    validations do
      required(:name).filled(:str?, :name?, max_size?: 255)
      required(:label).filled(:str?, max_size?: 255)
      required(:type).filled(:str?)
      optional(:order).maybe(:int?)
      optional(:hidden).maybe(:bool?)
      # rubocop:disable all
      optional(:attr_mappings) { array? { each { schema {
        required(:provider).schema {
          predicates NamePredicates
          required(:name).filled(:str?, :name?, max_size?: 255)
        }
        required(:name).maybe(:str?, max_size?: 255)
        optional(:conversion).maybe(:str?)
      } } } }
      # rubocop:enable all
      optional(:code).maybe(:str?, max_size?: 1024)
    end
  end

  expose :attr

  def initialize(attr_repository: AttrRepository.new,
                 provider_repository: ProviderRepository.new)
    @attr_repository = attr_repository
    @provider_repository = provider_repository
  end

  def call(params)
    params = params.to_h.dup

    if params[:attr_mappings]
      params[:attr_mappings] = params[:attr_mappings]
        .reject { |am_params| am_params[:name].nil? || am_params[:name].empty? }
        .map do |am_params|
        {
          **am_params.slice(:name, :conversion),
          provider_id: provider_id_by_name(am_params.dig(:provider, :name)),
        }
      end
    end

    params[:order] ||= @attr_repository.last_order + 8
    @attr = @attr_repository.create_with_mappings(params)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    result = true

    if @attr_repository.exist_by_name?(params[:name])
      error({name: [I18n.t('errors.uniq?')]})
      result = false
    end

    if @attr_repository.exist_by_label?(params[:label])
      error({label: [I18n.t('errors.uniq?')]})
      result = false
    end

    if params[:order] && @attr_repository.exist_by_order?(params[:order])
      error({order: [I18n.t('errors.uniq?')]})
      result = false
    end

    if params[:attr_mappings]
      params[:attr_mappings].each_with_index do |am_params, idx|
        if provider_id_by_name(am_params.dig(:provider, :name)).nil?
          error({attr_mappings: {idx => {provider: {name: [I18n.t('errors.found?')]}}}})
          result = false
        end
      end
    end

    result
  end

  private def named_providers
    @named_providers ||= @provider_repository.all.to_h { |provider| [provider.name, provider.id] }
  end

  private def provider_id_by_name(name)
    named_providers[name]
  end
end
