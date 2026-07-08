# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Password
          class Update < API::Action
            include Deps[
              "repos.service_repo",
              "repos.user_repo",
              "services.change_password_user",
            ]

            security_level 3

            contract do
              params do
                required(:service_id).filled(:str?, max_size?: MAX_STRING_SIZE)
                required(:user_id).filled(:str?, max_size?: MAX_STRING_SIZE)

                required(:password).filled(:password, max_size?: MAX_STRING_SIZE)
              end

              rule(:service_id).validate(:name)
              rule(:user_id).validate(:name)

              rule(:password).validate(:password)
            end

            def handle(request, response)
              check_params(request, response)

              service = srevice_repo.get!(request.params[:service_id])
              user = user_repo.get!(request.params[:usner_id])
              password = request.params[:password]

              result = change_password_user.call(service, user.name, password)
              take_result(request, response, result)

              response.status = :created
              response.format = :json
              response.body = {password:}.to_json
            end
          end
        end
      end
    end
  end
end
