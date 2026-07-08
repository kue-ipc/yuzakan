# frozen_string_literal: true

module API
  module Actions
    module Services
      class Update < API::Action
        include Deps[
          "adapter_repo",
          "repos.service_repo",
          view: "views.services.show",
        ]

        security_level 5

        contract do
          params do
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)

            optional(:label).maybe(:str?, max_size?: MAX_STRING_SIZE)
            optional(:description).maybe(:str?, max_size?: MAX_TEXT_SIZE)

            optional(:order).filled(:int?)

            optional(:adapter).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:params) { hash? }

            optional(:readable).filled(:bool?)
            optional(:writable).filled(:bool?)

            optional(:authenticatable).filled(:bool?)
            optional(:password_changeable).filled(:bool?)
            optional(:lockable).filled(:bool?)

            optional(:group).filled(:bool?)

            optional(:individual_password).filled(:bool?)
            optional(:self_management).filled(:bool?)
          end

          rule(:id).validate(:name)
          rule(:adapter).validate(:name)
        end

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, service_repo)
          name = take_unique_name(request, response, service_repo)

          current = service_repo.get(id)
          adapter = adapter_repo.get(request.params[:adapter] || current.adapter)
          halt_json request, response, 422, invalid: {adapter: t("errors.found?")} unless adapter

          result = adapter.class.validate(request.params[:params] || current.params)
          halt_json request, response, 422, invalid: {params: result.errors} if result.failure?

          service = nil
          service_repo.transaction do
            service = service_repo.put!(id, **request.params, params: result.to_h)
            service_repo.renumber_order(service)
          end

          if id != name
            response.headers["Content-Location"] = "/api/services/#{name}"
            response[:location] = "/api/services/#{name}"
          end
          response[:service] = service
        end
      end
    end
  end
end
