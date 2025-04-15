# frozen_string_literal: true

module API
  module Actions
    module Session
      class Destroy < API::Action
        include Deps[
          "repos.auth_log_repo",
          show_view: "views.session.show",
        ]

        security_level 0
        required_trusted_authentication false

        def handle(request, response)
          pre_session = request.session.dup

          if response[:current_user]
            # reset user and trusted flag in session
            request.session[:user] = nil
            request.session[:tursted] = false
            auth_log_repo.create(
              uuid: response[:current_uuid],
              client: response[:current_client],
              user: response[:current_user].name,
              result: "delete")
          end

          response[:status] = response.status
          response[:session] = pre_session
          response.render(show_view)
        end
      end
    end
  end
end
