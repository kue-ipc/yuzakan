# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Mfa
          class Destroy < API::Action
            include Deps[
              "repos.service_repo",
              "repos.user_repo",
              "services.reset_mfa_user",
            ]

            security_level 1

            contract Validation::UserServiceContract

            def handle(request, response)
              check_params(request, response)

              service = srevice_repo.get!(request.params[:service_id])

              user =
                if request.params[:user_id] == "~"
                  # current user mode
                  response[:current_user]
                else
                  # can reset MFA for other users by operator
                  reply_unauthorized(request, response) unless response[:current_level] >= 3

                  user_repo.get!(request.params[:user_id])
                end

              result = reset_mfa_user.call(service, user.name)
              mfa = take_result(request, response, result)

              response.status = :created
              response.format = :json
              response.body = mfa.to_json
            end
          end
        end
      end
    end
  end
end
