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
          service_repo.transaction do
            service = service_repo.set(name, **request.params, order:, params: result.to_h)
            service_repo.renumber_order(service)
          end

          response.status = :created
          response.headers["Content-Location"] = "/api/services/#{name}"
          response[:location] = "/api/services/#{name}"
          response[:service] = service
          response.render(show_view)
        end

        private def next_order
          service_repo.last_order + 1
        end
      end
    end
  end
end
