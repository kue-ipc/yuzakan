# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    include Deps["logger"]

    # Other modules
    include Yuzakan::Actions::Flash
    include Yuzakan::Actions::Connection

    # HACK: HanamiのコードではDry::Vlaidation::Contractにハードコードされている
    #       ため、configを設定した任意のサブクラスでContractが作られない。
    #       参照: hanami-action-3.0.1/lib/hanami/action/validation.rb
    def self.params(klass = nil, &block)
      contract_class = klass || Class.new(Yuzakan::Validation::ActionContract) { params(&block) }

      config.contract_class = contract_class
    end

    def self.contract(klass = nil, &)
      contract_class = klass || Class.new(Yuzakan::Validation::ActionContract, &)

      config.contract_class = contract_class
    end

    # override methods

    # skip to verify csrf token if Sec-Fetch-Site is same-origin.
    def verify_csrf_token?(req, *)
      super && req.get_header("HTTP_SEC_FETCH_SITE") != "same-origin"
    end

    # handle

    handle_exception StandardError => :handle_standard_error if Hanami.env?(:produciton)
    handle_exception InvalidCSRFTokenError => :handle_invalid_csrf_token_error

    private def handle_standard_error(_request, _response, exception)
      logger.error exception
      halt 500
    end

    private def handle_invalid_csrf_token_error(request, _response, _exception)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN], was: request_csrf_token(request),
        fetch_site: req.get_header("HTTP_SEC_FETCH_SITE")
      halt 400
    end
  end
end
