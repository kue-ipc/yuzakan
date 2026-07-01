# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Password
          class Create < API::Action
            include Deps[
              "repos.service_repo",
              "repos.user_repo",
              "operations.generate_password",
              "services.change_password_user",
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
                  # can reset password for other users by operator
                  reply_unauthorized(request, response) unless response[:current_level] >= 3

                  user_repo.get!(request.params[:user_id])
                end

              generate_result = generate_password.call
              password = take_result(request, response, generate_result)
              change_result = change_password_user.call(service, user.name, password)
              take_result(request, response, change_result)

              response.status = :created
              response.format = :json
              response.body = {password: password}.to_json
            end
          end
        end
      end
    end
  end
end
