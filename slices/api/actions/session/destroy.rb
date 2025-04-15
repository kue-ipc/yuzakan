# frozen_string_literal: true

module API
  module Actions
    module Session
      class Destroy < API::Action
        security_level 0
        required_trusted_authentication false

        def handle(req, res)
          pre_session = req.session.dup

          if res[:current_user]
            # reset user and trusted flag in session
            req.session[:user] = nil
            req.session[:tursted] = false
            auth_log_repo.create(
              uuid: res[:current_uuid],
              client: res[:current_client],
              user: res[:current_user].name,
              result: "delete")
          end

          res[:status] = res.status
          res[:session] = pre_session
        end
      end
    end
  end
end
