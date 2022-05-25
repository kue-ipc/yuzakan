require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateAttr
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    predicates NamePredicates
    messages :i18n

    validations do
      optional(:name).filled(:str?, :name?, max_size?: 255)
      optional(:label).filled(:str?, max_size?: 255)
      optional(:type).filled(:str?, max_size?: 255)
      optional(:order).maybe(:int?, gt?: 0)
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
      optional(:code).maybe(:str?, max_size?: 4096)
    end
  end

  expose :attr

  def initialize(attr:,
                 attr_repository: AttrRepository.new,
                 attr_mapping_repository: AttrMappingRepository.new,
                 provider_repository: ProviderRepository.new)
    @attr = attr
    @attr_repository = attr_repository
    @attr_mapping_repository = attr_mapping_repository
    @provider_repository = provider_repository
  end

  def call(params)
    params = params.to_h.dup

    if params[:attr_mappings]
      params[:attr_mappings] = params[:attr_mappings].map do |am_params|
        {
          **am_params.slice(:name, :conversion),
          provider_id: provider_id_by_name(am_params.dig(:provider, :name)),
        }
      end
    end

    @attr_repository.update(@attr.id, params)

    params[:attr_mappings]&.each do |am_params|
      if am_params[:name] && !am_params[:name].empty?
        existing_attr_mapping = @attr.attr_mappings.find do |mapping|
          mapping.provider_id == am_params[:provider_id]
        end

        if existing_attr_mapping
          @attr_mapping_repository.update(existing_attr_mapping.id, am_params)
        else
          @attr_repository.add_mapping(@attr, am_params)
        end
      else
        @attr_repository.delete_mapping_by_provider_id(@attr, am_params[:provider_id])
      end
    end

    @attr = @attr_repository.find_with_mappings(@attr.id)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    result = true

    if params[:name] && @attr.name != params[:name] && @attr_repository.exist_by_name?(params[:name])
      error({name: [I18n.t('errors.uniq?')]})
      result = false
    end

    if params[:label] && @attr.label != params[:label] && @attr_repository.exist_by_label?(params[:label])
      error({label: [I18n.t('errors.uniq?')]})
      result = false
    end

    if params[:order] && @attr.order != params[:order] && @attr_repository.exist_by_order?(params[:order])
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
