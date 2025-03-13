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

    private def reply_uninitialized(_request, _response)
      halt_json 503, errors: [t("messages.uninitialized")]
    end

    private def reply_unauthenticated(_request, _response)
      halt_json 401
    end

    private def reply_unauthorized(_request, _response)
      halt_json 403
    end

    private def reply_session_timeout(_request, _response)
      halt_json 401, errors: [t("messages.session_timeout")]
    end

    # override handle

    def handle_standard_error(request, response, exception)
      logger.error exception
      halt_json 500
    end

    def handle_invalid_csrf_token(request, response)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN],
        was: request.params.raw[CSRF_TOKEN.to_s]
      halt_json 400, errors: [I18n.t("errors.invalid_csrf_token")]
    end
  end
end
