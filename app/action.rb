# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    include Yuzakan::Actions::Flash
    include Yuzakan::Actions::Connection
    include Yuzakan::Actions::I18n

    # HACK: HanamiのコードではDry::Vlaidation::Contractにハードコードされている
    #        ため、configを設定した任意のサブクラスでContractが作られない。
    class Params < Hanami::Action::Params
      def self.params(&block)
        @_contract = Class.new(Yuzakan::Validation::ActionContract) { params(&block || -> {}) }.new
      end
    end

    def self.params(klass = nil, &block)
      contract_class =
        if klass.nil?
          Class.new(Yuzakan::Validation::ActionContract) { params(&block) }
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

    include Deps["logger"]

    # Cache
    include Hanami::Action::Cache

    cache_control :private, :no_cache

    # handle

    handle_exception StandardError => :handle_standard_error if Hanami.env?(:produciton)
    handle_exception InvalidCSRFTokenError => :handle_invalid_csrf_token_error

    private def handle_standard_error(_request, _response, exception)
      logger.error exception
      halt 500
    end

    private def handle_invalid_csrf_token_error(request, _response, _exception)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN], was: request_csrf_token(request)
      halt 400
    end
  end
end
