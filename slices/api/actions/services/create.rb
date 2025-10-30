# frozen_string_literal: true

module API
  module Actions
    module Services
      class Create < API::Action
        include Deps[
          "adapter_repo",
          "repos.service_repo",
          show_view: "views.services.show"
        ]

        security_level 5

        params do
          required(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          optional(:description).maybe(:str?, max_size?: 16383)

          optional(:order).filled(:int?)

          required(:adapter).filled(:name, max_size?: 255)
          required(:params) { hash? }

          optional(:readable).filled(:bool?)
          optional(:writable).filled(:bool?)

          optional(:authenticatable).filled(:bool?)
          optional(:password_changeable).filled(:bool?)
          optional(:lockable).filled(:bool?)

          optional(:group).filled(:bool?)

          optional(:individual_password).filled(:bool?)
          optional(:self_management).filled(:bool?)
        end

        def handle(request, response)
          check_params(request, response)
          name = take_unique_name(request, response, service_repo)

          adapter = adapter_repo.get(request.params[:adapter])
          unless adapter
            response.flash[:invalid] = {adapter: t("errors.found?")}
            halt_json request, response, 422
          end

          result = adapter.class.validate(request.params[:params])
          if result.failure?
            response.flash[:invalid] = {params: result.errors}
            halt_json request, response, 422
          end

          order = request.params[:order] || next_order

          service = nil
          serivce_repo.transaction do
            service = service_repo.set(name, **request.params, order:, params: result.to_h)
            service_repo.renumber_order(service)
          end

          response.status = :created
          response.headers["Content-Location"] = "/api/services/#{name}"
          response[:location] = "/api/services/#{name}"
          response[:service] = service
          response.render(show_view)
        end



          # unless params.valid?
          #   halt_json 400,
          #     errors: [only_first_errors(params.errors)]
          # end

          # halt_json 422, errors: [{name: [t("errors.uniq?")]}] if @service_repository.exist_by_name?(params[:name])

          # adapter_params = params.to_h.dup
          # adapter_params_params = adapter_params.delete(:params)
          # adapter_params[:order] ||= @service_repository.last_order + 8
          # service = @service_repository.create(adapter_params)

          # if adapter_params_params
          #   service.adapter_param_types.each do |param_type|
          #     value = param_type.convert_value(adapter_params_params[param_type.name])
          #     next if value.nil?

          #     data = {name: param_type.name.to_s,
          #             value: param_type.dump_value(value),}
          #     @service_repository.add_param(service, data)
          #   end
          # end

          # @name = params[:name]
          # load_service

          # self.status = 201
          # headers["Content-Location"] = routes.service_path(@name)
          # self.body = service_json
        # end

        private def next_order
          service_repo.last_order + 1
        end
      end
    end
  end
end
