# frozen_string_literal: true

require_relative "entity_provider"

module API
  module Actions
    module Providers
      class Create < API::Action
        include EntityProvider

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            optional(:label).maybe(:str?, max_size?: 255)
            required(:adapter).filled(:str?, :name?, max_size?: 255)
            optional(:order).filled(:int?)
            optional(:readable).filled(:bool?)
            optional(:writable).filled(:bool?)
            optional(:authenticatable).filled(:bool?)
            optional(:password_changeable).filled(:bool?)
            optional(:lockable).filled(:bool?)
            optional(:individual_password).filled(:bool?)
            optional(:self_management).filled(:bool?)
            optional(:group).filled(:bool?)
            optional(:params) { hash? }
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new,
          **opts)
          super
          @provider_repository ||= provider_repository
        end

        def handle(_request, _response)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          halt_json 422, errors: [{name: [t("errors.uniq?")]}] if @provider_repository.exist_by_name?(params[:name])

          adapter_params = params.to_h.dup
          adapter_params_params = adapter_params.delete(:params)
          adapter_params[:order] ||= @provider_repository.last_order + 8
          provider = @provider_repository.create(adapter_params)

          if adapter_params_params
            provider.adapter_param_types.each do |param_type|
              value = param_type.convert_value(adapter_params_params[param_type.name])
              next if value.nil?

              data = {name: param_type.name.to_s,
                      value: param_type.dump_value(value),}
              @provider_repository.add_param(provider, data)
            end
          end

          @name = params[:name]
          load_provider

          self.status = 201
          headers["Content-Location"] = routes.provider_path(@name)
          self.body = provider_json
        end
      end
    end
  end
end
