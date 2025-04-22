# auto_register: false
# frozen_string_literal: true

module API
  class Action < Yuzakan::Action
    include API::Actions::MessageJSON

    # FIXME: JSONで渡されるとrawでもキーがシンボルになっているが、
    #   CSRFProtectionではキーが文字列であることを前提としているため、
    #   CSRFトークンが探せなくて不正扱いになる。
    #   そのため、最初のチェックで文字列キーを生成しておく。
    def missing_csrf_token?(request, *)
      request.params.raw[CSRF_TOKEN.to_s] ||= request.params.raw[CSRF_TOKEN]
      Hanami::Utils::Blank.blank?(request.params.raw[CSRF_TOKEN.to_s])
    end

    # override reply

    private def reply_uninitialized(request, response)
      halt_json request, response, 503, errors: [t("messages.uninitialized")]
    end

    # TODO: メッセージを付けるべき？
    private def reply_unauthenticated(request, response)
      halt_json request, response, 401
    end

    # TODO: メッセージを付けるべき？
    private def reply_untrusted(request, response)
      halt_json request, response, 401
    end

    private def reply_unauthorized(request, response)
      halt_json request, response, 403
    end

    # override handle

    def handle_standard_error(request, response, exception)
      logger.error exception
      halt_json request, response, 500
    end

    def handle_invalid_csrf_token(request, response)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN],
        was: request.params.raw[CSRF_TOKEN.to_s]
      halt_json request, response, 400, errors: [t("errors.invalid_csrf_token")]
    end

    # override private api
    private def view_options(request, response)
      super.merge({status: response.status})
    end
  end
end
