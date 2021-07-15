require 'hanami/interactor'
require 'hanami/validations/form'

class UpdateAttr
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:name) { filled? & str? }
      required(:display_name) { str? }
      required(:type) { str? }

      optional(:order) { gt? 0 }
      optional(:hidden) { bool? }

      optional(:attr_mappings) { array? }
    end
  end

  expose :attr

  def initialize(attr: nil,
                 attr_repository: AttrRepository.new,
                 attr_mapping_repository: AttrMappingRepository.new,
                 provider_repository: ProviderRepository.new)
    @attr = attr
    @attr_repository = attr_repository
    @attr_mapping_repository = attr_mapping_repository
    @provider_repository = provider_repository
  end

  def call(params)
    params = params.dup
    params_attr_mappings = params.delete(:attr_mappings) || []

    @attr =
      if @attr
        @attr_repository.update(@attr.id, params)
      else
        unless params[:order]
          params[:order] = @attr_repository.last_order&.order.to_i + 1
        end
        @attr_repository.create(params)
      end

    params_attr_mappings.each do |attr_mapping_params|
      attr_mapping_params[:provider_id] ||=
        @provider_repository.find_by_name(attr_mapping_params[:provider_name])&.id
      next if attr_mapping_params[:provider_id].nil?

      attr_mapping = @attr_mapping_repository.find_by_provider_attr(
        attr_mapping_params[:provider_id], @attr.id)

      if attr_mapping_params[:name].nil? || attr_mapping_params[:name].empty?
        @attr_repository.remove_mapping(@attr, attr_mapping.id) if attr_mapping
        next
      end

      if attr_mapping_params[:conversion].nil? ||
         attr_mapping_params[:conversion].empty?
        attr_mapping_params[:conversion] = nil
      end

      if attr_mapping
        @attr_mapping_repository.update(attr_mapping.id, attr_mapping_params)
      else
        @attr_repository.add_mapping(@attr, attr_mapping_params)
      end
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    result = true

    if @attr
      # update
      if params[:name] != @attr.name &&
          @attr_repository.by_name(params[:name]).exist?
        error({name: ['その名前は既に存在します。']})
        result = false
      end

      if params[:display_name] != @attr.display_name &&
        @attr_repository.by_display_name(params[:display_name]).exist?
       error({display_name: ['その表示名は既に存在します。']})
       result = false
     end
    else
      # create
      if @attr_repository.by_name(params[:name]).exist?
        error({name: ['その名前は既に存在します。']})
        result = false
      end

      if @attr_repository.by_display_name(params[:display_name]).exist?
        error({display_name: ['その表示名は既に存在します。']})
        result = false
      end
    end

    result
  end
end
