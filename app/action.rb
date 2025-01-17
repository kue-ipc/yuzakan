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

    before :connect!
    before :check_session!
    before :configurate!
    before :authenticate!
    before :authorize!
    after :done!

    handle_exception StandardError => :handle_standard_error

    private def connect!(request, response)
      Hanami.logger.info(log_info(request, response))
    end

    private def check_session!(request, response)
      return if request.session[:user].nil?

      if request.session[:updated_at]
        timeout = current_config(request, response)&.session_timeout || 3600
        if timeout.zero? ||
            current_time(request, response) - session[:updated_at] > timeout
          request.session[:updated_at] = current_time
          return
        end
      end

      Hanam.logger.debug("session timout", user: request.session[:user])
      response.session[:user] = nil
      response.session[:created_at] = nil
      response.session[:updated_at] = nil

      flash[:warn] = I18n.t("messages.session_timeout")
      response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def configurate!(request, response)
      return if current_config

      reply_uninitialized(request, response)
    end

    private def authenticate!(request, response)
      return if self.class.security_level&.zero?
      return if current_user

      reply_unauthenticated(request, response)
    end

    private def authorize!(request, response)
      return if current_level(request, response) >= self.class.security_level

      reply_unauthorized(request, response)
    end

    private def done!(request, response)
      activity_log_repo.create(**log_info(request, response),
        status: response.status)
    end

    private def log_info(request, response)
      @log_info ||= {
        uuid: current_uuid(request, response),
        client: request.ip,
        user: current_user(request, response)&.name,
        action: self.class.name,
        method: request.request_method,
        path: request.path,
      }
    end

    private def current_time(_request, _response)
      @current_time ||= Time.now
    end

    private def current_uuid(request, _response)
      @current_uuid ||= request.session[:uuid] || SecureRandom.uuid
    end

    private def current_config(_request, _response)
      (@current_config ||= Maybe(config_repo.current)).value_or(nil)
    end

    private def current_user(request, _response)
      (@current_user ||= Maybe(user_repo.get(request.session[:user])))
        .value_or(nil)
    end

    # FIXME: unixドメイン経由やリバースプロキシ経由の場合の検証が必要。
    private def current_network(request, _response)
      (@current_network ||= Maybe(network_repo.find_by_ip(request.ip)))
        .value_or(nil)
    end

    private def current_level(request, response)
      (@current_level ||= Maybe([
        current_user(request, response)&.clearance_level || 0,
        current_network(request, response)&.clearance_level || 0,
      ].min)).value_or(nil)
    end

    private def reply_uninitialized(_request, response)
      response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def reply_unauthenticated(_request, response)
      response.flash[:warn] ||= I18n.t("messages.unauthenticated")
      response.redirect_to(Hanami.app["routes"].path(:root))
    end

    private def reply_unauthorized(request, response)
      halt 403
    end

    private def handle_standard_error(e)
      Hanami.logger.error e
      halt 500
    end
  end
end
