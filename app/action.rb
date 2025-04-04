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
      "repos.config_repo",
      "repos.network_repo",
      "repos.user_repo",
      "repos.action_log_repo",
      "i18n.t",
      "i18n.l",
      login_view: "views.home.login",
      mfa_view: "views.home.mfa",
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

    # required
    defines :required_configuration
    defines :required_authentication
    defines :required_trusted_authentication
    required_configuration true
    required_authentication true
    # effect only if required_authentication is true
    required_trusted_authentication true

    before :connect! # first
    before :configure!
    before :authenticate!
    before :authorize!
    after :done!

    if Hanami.env?(:produciton)
      handle_exception StandardError => :handle_standard_error
    end

    # callback methods

    private def connect!(req, res)
      return if res.has_header?(:current_connected) && res[:current_connected]

      res[:current_time] = Time.now
      res[:current_client] = req.ip
      raise "client ip is missing" unless res[:current_client]

      res[:current_config] = config_repo.current

      # check session timeout
      if req.session[:updated_at]
        timeout = res[:current_config]&.session_timeout
        if timeout&.positive? &&
            res[:current_time] - req.session[:updated_at] > timeout
          logger.debug "session timeout", user: req.session[:user],
            update_at: req.session[:updated_at]
          res.flash[:warn] = t.call("messages.session_timeout")
          res.session[:user] = nil
          res.session[:trusted] = false
        end
      end

      # initial session
      req.session[:uuid] ||= SecureRandom.uuid
      req.session[:user] ||= nil
      req.session[:trusted] ||= false
      req.session[:created_at] ||= res[:current_time]
      req.session[:updated_at] = res[:current_time]

      res[:current_uuid] = req.session[:uuid]
      res[:current_user] = req.session[:user]&.then { user_repo.get(_1) }

      res[:current_network] = network_repo.find_include(res[:current_client])

      res[:current_level] = [
        res[:current_user]&.clearance_level || 0,
        res[:current_network]&.clearance_level || 0,
      ].min
      res[:current_trusted] = res[:current_network]&.trusted ||
        req.session[:trusted] || false

      res[:current_connected] = true
    end

    # check current config, authentication, authorization
    private def configure!(req, res)
      connect!(req, res)
      return unless self.class.required_configuration
      return if res[:current_config]

      reply_uninitialized(req, res)
    end

    private def authenticate!(req, res)
      connect!(req, res)
      return unless self.class.required_authentication

      if res[:current_user]
        return unless self.class.required_trusted_authentication
        return if res[:current_trusted]

        reply_untrusted(req, res)
      end

      reply_unauthenticated(req, res)
    end

    private def authorize!(req, res)
      connect!(req, res)
      return if res[:current_level] >= self.class.security_level

      reply_unauthorized(req, res)
    end

    private def done!(req, res)
      log_info = {
        uuid: res[:current_uuid],
        client: res[:current_client],
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

    # TODO: メッセージを付けるべき？
    private def reply_unauthenticated(_req, res)
      halt 401, res.render(login_view)
    end

    # TODO: メッセージを付けるべき？
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
