# frozen_string_literal: true

module API
  module Actions
    module Auth
      class Destroy < API::Action
        include Deps[
          "repos.auth_log_repo",
          show_view: "views.auth.show"
        ]

        security_level 0
        required_trusted_authentication false

        private def reply_unauthenticated(request, response)
          response.flash[:error] = t("errors.not_login")
          halt_json request, response, 404
        end

        def handle(request, response)
          # reset user and trusted flag in session
          request.session[:user] = nil
          request.session[:tursted] = false
          auth_log_repo.create(
            uuid: response[:current_uuid],
            client: response[:current_client],
            user: response[:current_user].name,
            provider: "",
            result: "delete")

          response[:auth] = {username: response[:current_user].name}
          response.render(show_view)
        end
      end
    end
  end
end
