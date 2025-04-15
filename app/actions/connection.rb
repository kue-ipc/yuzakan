# auto_register: false
# frozen_string_literal: true

# security level
# level 0: guest
# level 1: user
# level 2: observer
# level 3: operator
# level 4: administrator
# level 5: superuser

module Yuzakan
  module Actions
    module Connection
      def self.included(action)
        action.include Yuzakan::Actions::Flash
        action.include Deps[
          "logger",
          "repos.config_repo",
          "repos.network_repo",
          "repos.user_repo",
          "repos.action_log_repo",
          login_view: "views.home.login",
          mfa_view: "views.home.mfa",
          unready_view: "views.home.unready",
        ]
        action.extend Dry::Core::ClassAttributes

        action.defines :security_level
        action.security_level 1

        # required
        action.defines :required_configuration
        action.defines :required_authentication
        action.defines :required_trusted_authentication
        action.required_configuration true
        action.required_authentication true
        # effect only if required_authentication is true
        action.required_trusted_authentication true

        action.before :check_connection
        action.after :record_log
      end

      # callback methods

      private def check_connection(request, response)
        response[:current_time] = current_time(request, response)
        response[:current_client] = current_client(request, response)
        response[:current_config] = current_config(request, response)

        check_session(request, response)

        response[:current_uuid] = current_uuid(request, response)
        response[:current_user] = current_user(request, response)
        response[:current_network] = current_network(request, response)
        response[:current_level] = current_level(request, response)
        response[:current_trusted] = current_trusted(request, response)

        check_configuration(request, response)
        check_authentication(request, response)
        check_authorization(request, response)
      end

      private def current_time(_request, _response) = Time.now
      private def current_client(request, _response)
        request.ip || raise("client ip is missing")
      end
      private def current_config(_request, _response) = config_repo.current
      private def current_uuid(request, response)
        raise "session unchecked" unless session_checked?(request, response)

        request.session[:uuid]
      end
      private def current_user(request, response)
        raise "session unchecked" unless session_checked?(request, response)

        request.session[:user]&.then { user_repo.get(_1) }
      end
      private def current_network(_request, response)
        network_repo.find_include(response[:current_client])
      end
      private def current_level(_request, response)
        [:current_user, :current_network]
          .map { response[_1]&.clearance_level || 0 }.min
      end

      private def current_trusted(request, response)
        raise "session unchecked" unless session_checked?(request, response)

        response[:current_network]&.trusted || request.session[:trusted] || false
      end

      # check

      private def check_session(request, response)
        # check session timeout
        if session_timeout?(request, response)
          logger.debug "session timeout", user: request.session[:user],
            update_at: request.session[:updated_at]
          add_flash(response, :warn, t("messages.session_timeout"))
          response.session[:user] = nil
          response.session[:trusted] = false
        end

        # initial session
        request.session[:uuid] ||= SecureRandom.uuid
        request.session[:user] ||= nil
        request.session[:trusted] ||= false
        request.session[:created_at] ||= response[:current_time]
        request.session[:updated_at] = response[:current_time]
      end

      private def session_timeout?(request, response)
        return false if request.session[:updated_at].nil?

        timeout = response[:current_config]&.session_timeout
        return false unless timeout&.positive?

        elapsed_time = response[:current_time] - request.session[:updated_at]
        return false if elapsed_time <= timeout

        true
      end

      private def session_checked?(request, response)
        request.session[:updated_at] == response[:current_time]
      end

      private def check_configuration(request, response)
        return unless self.class.required_configuration
        return if response[:current_config]

        reply_uninitialized(request, response)
      end

      private def check_authentication(request, response)
        return unless self.class.required_authentication

        if response[:current_user]
          return unless self.class.required_trusted_authentication
          return if response[:current_trusted]

          reply_untrusted(request, response)
        end

        reply_unauthenticated(request, response)
      end

      private def check_authorization(request, response)
        return if response[:current_level] >= self.class.security_level

        reply_unauthorized(request, response)
      end

      # after

      private def record_log(request, response)
        log_info = {
          uuid: response[:current_uuid],
          client: response[:current_client],
          user: response[:current_user]&.name,
          action: self.class.name,
          method: request.request_method,
          path: request.path,
          status: response.status,
        }
        logger.info("action", **log_info)
        action_log_repo.create(**log_info)
      end

      # reply

      private def reply_uninitialized(_request, response)
        add_flash(response, :error, t("errors.initialized?"))
        halt 503, response.render(unready_view)
      end

      private def reply_unauthenticated(_request, response)
        halt 401, response.render(login_view)
      end

      private def reply_untrusted(_request, response)
        halt 401, response.render(mfa_view)
      end

      private def reply_unauthorized(_request, _response)
        halt 403
      end
    end
  end
end
