# frozen_string_literal: true

module API
  module Actions
    module Services
      class Update < API::Action
        include Deps[
          "adapter_repo",
          "repos.service_repo",
          show_view: "views.services.show"
        ]

        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)

          optional(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          optional(:description).maybe(:str?, max_size?: 16383)

          optional(:order).filled(:int?)

          optional(:adapter).filled(:name, max_size?: 255)
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

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, service_repo)
          name = take_unique_name(request, response, service_repo)

          current = service_repo.get(id)
          adapter = adapter_repo.get(request.params[:adapter] || current.adapter)
          unless adapter
            response.flash[:invalid] = {adapter: t("errors.found?")}
            halt_json request, response, 422
          end

          result = adapter.class.validate(request.params[:params] || current.params)
          if result.failure?
            response.flash[:invalid] = {params: result.errors}
            halt_json request, response, 422
          end

          service = nil
          service_repo.transaction do
            service = service_repo.set(id, **request.params, params: result.to_h)
            service_repo.renumber_order(service)
          end

          if id != name
            response.headers["Content-Location"] = "/api/services/#{name}"
            response[:location] = "/api/services/#{name}"
          end
          response[:service] = service
          response.render(show_view)

        end
      end
    end
  end
end
