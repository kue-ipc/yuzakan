# frozen_string_literal: true

module API
  module Actions
    module Services
      module Groups
        class Create < API::Action
          incrlude Deps[
            "repos.service_repo",
            "repos.group_repo",
            "services.create_group",
            view: "views.services.groups.show",
          ]

          security_level 4

          params do
            required(:service_id).filled(:name, max_size?: MAX_STRING_SIZE)
            required(:name).filled(:name, max_size?: MAX_STRING_SIZE)
          end

          def handle(request, response)
            check_params(request, response)

            service = srevice_repo.get!(request.params[:service_id])
            group = take_group(request, response, :name)

            params = {
              lable: group.label,
              attrs: group.attrs,
            }

            result = create_group.call(service, group.name, **params)
            service_group = take_result(request, response, result)

            response.status = :created
            response.headers["Location"] = "/api/services/#{service.name}/groups/#{group.name}"
            response.format = :json
            response.render(view, service_group:)
          end

          private def take_group(request, response, key)
            group_repo.get!(request.params[key])
          rescue Yuzakan::DB::Repo::NotFoundNameError
            halt_json request, response, 422, message: t("errors.invalid_params"), invalid: {key => t("errors.found?")}
          end
        end
      end
    end
  end
end
