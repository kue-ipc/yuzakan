# frozen_string_literal: true

module API
  module Actions
    module Services
      class Create < API::Action
        include Deps[
          "adapter_repo",
          "repos.service_repo",
          view: "views.services.show",
        ]

        security_level 5

        contract do
          params do
            required(:name).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:label).value(:str?, max_size?: MAX_STRING_SIZE)
            optional(:description).value(:str?, max_size?: MAX_TEXT_SIZE)

            optional(:order).filled(:int?)

            required(:adapter).filled(:str?, max_size?: MAX_STRING_SIZE)
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

          rule(:name).validate(:name)
          rule(:adapter).validate(:name)
        end

        def handle(request, response)
          check_params(request, response)

          request.params[:name]
          request.params.to_h.slice(:label, :description, :readable, :writable, :authenticatable,
            :password_changeable, :lockable, :group, :individual_password, :self_management)

          adapter = take_adapter(request, response)
          params[:adapter] = adapter.name

          result = adapter.class.validate(request.params[:params])
          halt_json request, response, 422, invalid: {params: result.errors} if result.failure?

          params[:params] = result.to_h

          params[:order] = request.params[:order] || next_order

          service_repo.transaction do
            service = service_repo.set!(name, **params)
            service_repo.renumber_order(service)
          end
          service = service_repo.get_with_associations(name)

          response.status = :created
          response.headers["Location"] = "/api/services/#{name}"
          response.format = :json
          response.render(view, service:)
        end

        private def take_adapter(request, response)
          adapter_repo.get!(request.params[:adapter])
        rescue Yuzakan::DB::Repo::NotFoundNameError
          halt_json request, response, 422, message: t("errors.invalid_params"), invalid: {adapter: t("errors.found?")}
        end

        private def next_order
          service_repo.last_order + 1
        end
      end
    end
  end
end
