# auto_register: false
# frozen_string_literal: true

module API
  class Action < Yuzakan::Action
    include API::Actions::MessageJSON

    # FIXME: JSONで渡されるとrawでもキーがシンボルになっているが、
    #   CSRFProtectionではキーが文字列であることを前提としているため、
    #   CSRFトークンが探せなくて不正扱いになる。
    #   そのため、最初のチェックで文字列キーを生成しておく。
    def missing_csrf_token?(req, *)
      req.params.raw[CSRF_TOKEN.to_s] ||= req.params.raw[CSRF_TOKEN]
      Hanami::Utils::Blank.blank?(req.params.raw[CSRF_TOKEN.to_s])
    end

    # override reply

    private def reply_uninitialized(_req, _res)
      halt_json 503, errors: [t.call("messages.uninitialized")]
    end

    private def reply_unauthenticated(_req, _res)
      halt_json 401
    end

    private def reply_unauthorized(_req, _res)
      halt_json 403
    end

    private def reply_session_timeout(_req, _res)
      halt_json 401, errors: [t.call("messages.session_timeout")]
    end

    # override handle

    def handle_standard_error(req, res, exception)
      logger.error exception
      halt_json 500
    end

    def handle_invalid_csrf_token(req, res)
      logger.warn "CSRF attack", expected: req.session[CSRF_TOKEN],
        was: req.params.raw[CSRF_TOKEN.to_s]
      halt_json 400, errors: [t.call("errors.invalid_csrf_token")]
    end
  end
end
