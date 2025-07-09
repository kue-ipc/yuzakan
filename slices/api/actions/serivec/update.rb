# frozen_string_literal: true

require_relative "set_service"

module API
  module Actions
    module Services
      class Update < API::Action
        include SetService

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:adapter).filled(:str?, :name?, max_size?: 255)
            optional(:label).maybe(:str?, max_size?: 255)
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

        def initialize(service_repository: ServiceRepository.new,
          adapter_param_repository: AdapterParamRepository.new,
          **opts)
          super
          @service_repository ||= service_repository
          @adapter_param_repository ||= adapter_param_repository
        end

        def handle(_request, _response)
          change_name = params[:name] && params[:name] != @service.name
          if change_name && @service_repository.exist_by_name?(params[:name])
            halt_json 422, errors: [{name: [t("errors.uniq?")]}]
          end

          adapter_params = params.to_h.except(:id)
          adapter_params_params = adapter_params.delete(:params)
          @service_repository.update(@service.id, adapter_params)

          if adapter_params_params
            existing_params = @service.params.dup
            @service.adapter_param_types.each do |param_type|
              value = param_type.convert_value(adapter_params_params[param_type.name])
              next if value.nil?

              data = {name: param_type.name.to_s,
                      value: param_type.dump_value(value),}
              if existing_params.key?(param_type.name)
                existing_value = existing_params.delete(param_type.name)

                if existing_value != value
                  param_name = param_type.name.to_s
                  existing_adapter_param = @service.adapter_params.find do |param|
                    param.name == param_name
                  end
                  if existing_adapter_param
                    @adapter_param_repository.update(
                      existing_adapter_param.id, data)
                  else
                    # 名前がないということはあり得ない？
                    @service_repository.add_param(@service, data)
                  end
                end
              else
                @service_repository.add_param(@service, data)
              end
            end
            existing_params.each_key do |key|
              @service_repository.delete_param_by_name(@service, key.to_s)
            end
          end

          @name = params[:name] if change_name
          load_service

          self.status = 200
          if change_name
            headers["Content-Location"] =
              routes.service_path(@name)
          end
          self.body = service_json
        end
      end
    end
  end
end
