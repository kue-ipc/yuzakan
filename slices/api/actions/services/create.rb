# frozen_string_literal: true

module API
  module Actions
    module Services
      class Create < API::Action
        security_level 5

        params do
          required(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          required(:adapter).filled(:name, max_size?: 255)
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

        def initialize(service_repository: ServiceRepository.new,
          **opts)
          super
          @service_repository ||= service_repository
        end

        def handle(_request, _response)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          halt_json 422, errors: [{name: [t("errors.uniq?")]}] if @service_repository.exist_by_name?(params[:name])

          adapter_params = params.to_h.dup
          adapter_params_params = adapter_params.delete(:params)
          adapter_params[:order] ||= @service_repository.last_order + 8
          service = @service_repository.create(adapter_params)

          if adapter_params_params
            service.adapter_param_types.each do |param_type|
              value = param_type.convert_value(adapter_params_params[param_type.name])
              next if value.nil?

              data = {name: param_type.name.to_s,
                      value: param_type.dump_value(value),}
              @service_repository.add_param(service, data)
            end
          end

          @name = params[:name]
          load_service

          self.status = 201
          headers["Content-Location"] = routes.service_path(@name)
          self.body = service_json
        end
      end
    end
  end
end
