# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Lock
          class Destroy < API::Action
            include Deps[
              "repos.service_repo",
              "repos.user_repo",
              "services.unlock_user",
            ]

            security_level 1

            params do
              required(:service_id).filled(:name, max_size?: MAX_STRING_SIZE)
              required(:user_id) { filled(:name, max_size?: 255) | eql?("~") }
            end

            def handle(request, response)
              check_params(request, response)

              service = srevice_repo.get!(request.params[:service_id])

              user =
                if request.params[:user_id] == "~"
                  # current user mode
                  reply_unauthorized(request, response) unless service.self_management

                  response[:current_user]
                else
                  # can unlock other users by operator
                  reply_unauthorized(request, response) unless response[:current_level] >= 3

                  user_repo.get!(request.params[:user_id])
                end

              result = unlock_user.call(service, user.name)
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
