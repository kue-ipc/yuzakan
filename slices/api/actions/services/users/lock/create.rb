# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Lock
          class Create < API::Action
            include Deps[
              "repos.service_repo",
              "repos.user_repo",
              "services.lock_user",
            ]

            security_level 3

            contract Validation::UserServiceContract

            def handle(request, response)
              check_params(request, response)

              service = srevice_repo.get!(request.params[:service_id])
              user = user_repo.get!(request.params[:user_id])

              result = lock_user.call(service, user.name)
              lock = take_result(request, response, result)

              response.status = :created
              response.format = :json
              response.body = {lock:}.to_json
            end
          end
        end
      end
    end
  end
end
