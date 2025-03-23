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
      "logger",
      "repos.config_repo",
      "repos.network_repo",
      "repos.user_repo",
      "repos.action_log_repo",
      "i18n.t",
      "i18n.l",
      login_view: "views.home.login",
      unready_view: "views.home.unready",
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

    # callback methods

    private def connect!(req, res)
      res[:current_time] = Time.now
      res[:current_uuid] = (req.session[:uuid] ||= SecureRandom.uuid)
      res[:current_config] = config_repo.current
      res[:current_user] = user_repo.get(req.session[:user])
      res[:current_network] = network_repo.find_include(req.ip)
      res[:current_level] = [
        res[:current_user]&.clearance_level || 0,
        res[:current_network]&.clearance_level || 0,
      ].min
    end

    private def check_session!(req, res)
      return if req.session[:user].nil?

      if req.session[:updated_at]
        timeout = res[:current_config].session_timeout
        if timeout.zero? ||
            res[:current_time] - req.session[:updated_at] <= timeout
          res.session[:updated_at] = res[:current_time]
          return
        end
      end

      logger.debug "session timeout", user: req.session[:user],
        update_at: req.session[:updated_at]
      res.session[:user] = nil
      res.session[:created_at] = nil
      res.session[:updated_at] = nil

      reply_session_timeout(req, res)
    end

    private def configurate!(req, res)
      return if res[:current_config]

      reply_uninitialized(req, res)
    end

    private def authenticate!(req, res)
      return if self.class.security_level&.zero?
      return if res[:current_user]

      reply_unauthenticated(req, res)
    end

    private def authorize!(req, res)
      return if res[:current_level] >= self.class.security_level

      reply_unauthorized(req, res)
    end

    private def done!(req, res)
      log_info = {
        uuid: res[:current_uuid],
        client: req.ip,
        user: res[:current_user]&.name,
        action: self.class.name,
        method: req.request_method,
        path: req.path,
        status: res.status,
      }
      logger.info(log_info)
      action_log_repo.create(**log_info)
    end

    # reply

    private def reply_uninitialized(_req, res)
      halt 503, res.render(unready_view)
    end

    private def reply_unauthenticated(_req, res)
      halt 401, res.render(login_view)
    end

    private def reply_unauthorized(_req, _res)
      halt 403
    end

    private def reply_session_timeout(_req, res)
      res.flash[:warn] = t.call("messages.session_timeout")
      res.redirect_to(Hanami.app["routes"].path(:root))
    end

    # handle

    private def handle_standard_error(_req, _res, exception)
      logger.error exception
      halt 500
    end
  end
end
