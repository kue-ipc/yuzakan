# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    # HACK: HanamiのコードではDry::Vlaidation::Contractにハードコードされている
    #        ため、configを設定した任意のサブクラスでContractが作られない。
    class Params < Hanami::Action::Params
      def self.params(&block)
        @_contract = Class.new(Yuzakan::ValidationContract) {
          params(&block || -> {})
        }.new
      end
    end

    def self.params(klass = nil, &block)
      contract_class =
        if klass.nil?
          Class.new(Yuzakan::ValidationContract) { params(&block) }
        elsif klass < Hanami::Action::Params
          # Handle subclasses of Hanami::Action::Params.
          klass._contract.class
        else
          klass
        end

      config.contract_class = contract_class
    end

    def self.contract(klass = nil, &)
      contract_class = klass || Class.new(Yuzakan::ValidationContract, &)

      config.contract_class = contract_class
    end

    extend Dry::Core::ClassAttributes

    include Dry::Monads[:result]
    include Dry::Monads[:maybe]

    include Deps[
      "logger",
      "i18n",
      "repos.config_repo",
      "repos.network_repo",
      "repos.user_repo",
      "repos.action_log_repo",
      login_view: "views.home.login",
      mfa_view: "views.home.mfa",
      unready_view: "views.home.unready",
    ]

    # I18n
    private def t(...) = i18n.t(...)
    private def l(...) = i18n.l(...)

    # Flash
    private def add_flash(res, level, msg, now: true)
      if now
        res.flash.now[level] ||= []
        res.flash.now[level] << msg
      else
        # keep only one message
        res.flash[level] = [msg]
      end
    end

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

    # required
    defines :required_configuration
    defines :required_authentication
    defines :required_trusted_authentication
    required_configuration true
    required_authentication true
    # effect only if required_authentication is true
    required_trusted_authentication true

    before :check_connection
    after :record_log

    if Hanami.env?(:produciton)
      handle_exception StandardError => :handle_standard_error
    end

    # callback methods

    private def check_connection(req, res)
      res[:current_time] = current_time(req, res)
      res[:current_client] = current_client(req, res)
      res[:current_config] = current_config(req, res)

      check_session(req, res)

      res[:current_uuid] = current_uuid(req, res)
      res[:current_user] = current_user(req, res)
      res[:current_network] = current_network(req, res)
      res[:current_level] = current_level(req, res)
      res[:current_trusted] = current_trusted(req, res)

      check_configuration(req, res)
      check_authentication(req, res)
      check_authorization(req, res)
    end

    private def current_time(_req, _res) = Time.now
    private def current_client(req, _res)
      req.ip || raise("client ip is missing")
    end
    private def current_config(_req, _res) = config_repo.current
    private def current_uuid(req, res)
      raise "session unchecked" unless session_checked?(req, res)

      req.session[:uuid]
    end
    private def current_user(req, res)
      raise "session unchecked" unless session_checked?(req, res)

      req.session[:user]&.then { user_repo.get(_1) }
    end
    private def current_network(_req, res)
      network_repo.find_include(res[:current_client])
    end
    private def current_level(_req, res)
      [:current_user, :current_network]
        .map { res[_1]&.clearance_level || 0 }.min
    end

    private def current_trusted(req, res)
      raise "session unchecked" unless session_checked?(req, res)

      res[:current_network]&.trusted || req.session[:trusted] || false
    end

    # check

    private def check_session(req, res)
      # check session timeout
      if session_timeout?(req, res)
        logger.debug "session timeout", user: req.session[:user],
          update_at: req.session[:updated_at]
        add_flash(res, :warn, t("messages.session_timeout"))
        res.session[:user] = nil
        res.session[:trusted] = false
      end

      # initial session
      req.session[:uuid] ||= SecureRandom.uuid
      req.session[:user] ||= nil
      req.session[:trusted] ||= false
      req.session[:created_at] ||= res[:current_time]
      req.session[:updated_at] = res[:current_time]
    end

    private def session_timeout?(req, res)
      return false if req.session[:updated_at].nil?

      timeout = res[:current_config]&.session_timeout
      return false unless timeout&.positive?

      elapsed_time = res[:current_time] - req.session[:updated_at]
      return false if elapsed_time <= timeout

      true
    end

    private def session_checked?(req, res)
      req.session[:updated_at] == res[:current_time]
    end

    private def check_configuration(req, res)
      return unless self.class.required_configuration
      return if res[:current_config]

      reply_uninitialized(req, res)
    end

    private def check_authentication(req, res)
      return unless self.class.required_authentication

      if res[:current_user]
        return unless self.class.required_trusted_authentication
        return if res[:current_trusted]

        reply_untrusted(req, res)
      end

      reply_unauthenticated(req, res)
    end

    private def check_authorization(req, res)
      return if res[:current_level] >= self.class.security_level

      reply_unauthorized(req, res)
    end

    # after

    private def record_log(req, res)
      log_info = {
        uuid: res[:current_uuid],
        client: res[:current_client],
        user: res[:current_user]&.name,
        action: self.class.name,
        method: req.request_method,
        path: req.path,
        status: res.status,
      }
      logger.info("action", **log_info)
      action_log_repo.create(**log_info)
    end

    # reply

    private def reply_uninitialized(_req, res)
      add_flash(res, :error, t("errors.initialized?"))
      halt 503, res.render(unready_view)
    end

    private def reply_unauthenticated(_req, res)
      halt 401, res.render(login_view)
    end

    private def reply_untrusted(_req, res)
      halt 401, res.render(mfa_view)
    end

    private def reply_unauthorized(_req, _res)
      halt 403
    end

    # handle

    private def handle_standard_error(_req, _res, exception)
      logger.error exception
      halt 500
    end
  end
end
