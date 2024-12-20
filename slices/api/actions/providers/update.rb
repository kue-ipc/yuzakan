# frozen_string_literal: true

require_relative "set_provider"

module API
  module Actions
    module Providers
      class Update < API::Action
        include SetProvider

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:adapter).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
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
                       provider_param_repository: ProviderParamRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @provider_param_repository ||= provider_param_repository
        end

        def handle(_request, _response)
          change_name = params[:name] && params[:name] != @provider.name
          if change_name && @provider_repository.exist_by_name?(params[:name])
            halt_json 422, errors: [{name: [I18n.t("errors.uniq?")]}]
          end

          provider_params = params.to_h.except(:id)
          provider_params_params = provider_params.delete(:params)
          @provider_repository.update(@provider.id, provider_params)

          if provider_params_params
            existing_params = @provider.params.dup
            @provider.adapter_param_types.each do |param_type|
              value = param_type.convert_value(provider_params_params[param_type.name])
              next if value.nil?

              data = {name: param_type.name.to_s,
                      value: param_type.dump_value(value),}
              if existing_params.key?(param_type.name)
                existing_value = existing_params.delete(param_type.name)

                if existing_value != value
                  param_name = param_type.name.to_s
                  existing_provider_param = @provider.provider_params.find do |param|
                    param.name == param_name
                  end
                  if existing_provider_param
                    @provider_param_repository.update(
                      existing_provider_param.id, data)
                  else
                    # 名前がないということはあり得ない？
                    @provider_repository.add_param(@provider, data)
                  end
                end
              else
                @provider_repository.add_param(@provider, data)
              end
            end
            existing_params.each_key do |key|
              @provider_repository.delete_param_by_name(@provider, key.to_s)
            end
          end

          @name = params[:name] if change_name
          load_provider

          self.status = 200
          if change_name
            headers["Content-Location"] =
              routes.provider_path(@name)
          end
          self.body = provider_json
        end
      end
    end
  end
end
