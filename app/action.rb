# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    extend Dry::Core::ClassAttributes

    include Dry::Monads[:result]
    include Dry::Monads[:maybe]

    include Deps[
      "repos.config_repo",
      "repos.network_repo",
      "repos.user_repo",
      "repos.activity_log_repo",
      login_view: "views.home.login"
    ]

    # Cache
    include Hanami::Action::Cache
    cache_control :private, :no_cache

    # security level
    # level 0: anonymous
    # level 1: limited user
    # level 2: user
    # level 3: observer admin
    # level 4: operator admin
    # level 5: admin
    defines :security_level
    security_level 1

    before :connect! # first
    before :check_session!
    before :configurate!
    before :authenticate!
    before :authorize!
    after :done!

    Hanami.env["produciton"] do
      handle_exception StandardError => :handle_standard_error
    end

    private def connect!(request, response)
      response[:current_time] = Time.now
      response[:current_uuid] = request.session[:uuid] || SecureRandom.uuid
      response[:current_config] = config_repo.current
      response[:current_user] = user_repo.get(request.session[:user])
      response[:current_network] = network_repo.find_include_address(request.ip)
      response[:current_level] = [
        response[:current_user]&.clearance_level || 0,
        response[:current_network]&.clearance_level || 0,
      ].min
    end

    private def check_session!(request, response)
      return if request.session[:user].nil?

      if request.session[:updated_at]
        timeout = response[:current_config]&.session_timeout
        if timeout && (timeout.zero? ||
            response[:current_time] - session[:updated_at] > timeout)
          request.session[:updated_at] = response[:current_time]
          return
        end
      end

      Hanam.logger.debug("session timout", user: request.session[:user])
      response.session[:user] = nil
      response.session[:created_at] = nil
      response.session[:updated_at] = nil

      reply_session_timeout(request, response)
    end

    private def configurate!(request, response)
      return if response[:current_config]

      reply_uninitialized(request, response)
    end

    private def authenticate!(request, response)
      return if self.class.security_level&.zero?
      return if response[:current_user]

      reply_unauthenticated(request, response)
    end

    private def authorize!(request, response)
      return if response[:current_level] >= self.class.security_level

      reply_unauthorized(request, response)
    end

    private def done!(request, response)
      log_info = {
        uuid: response[:current_uuid],
        client: request.ip,
        user: response[:current_user]&.name,
        action: self.class.name,
        method: request.request_method,
        path: request.path,
        status: response.status,
      }
      Hanami.logger.info(log_info)
      activity_log_repo.create(**log_info)
    end

    # reply

    private def reply_uninitialized(_request, response)
      response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def reply_unauthenticated(_request, response)
      halt 401, response.render(login_view)
      # response.render(login_view)
      # response.flash[:warn] ||= I18n.t("messages.unauthenticated")
      # response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def reply_unauthorized(_request, _response)
      halt 403
    end

    private def reply_session_timeout(_request, response)
      flash[:warn] = I18n.t("messages.session_timeout")
      response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def handle_standard_error(request, response, exception)
      Hanami.logger.error exception
      halt 500
    end
  end
end
