# auto_register: false
# frozen_string_literal: true

module API
  class Action < Yuzakan::Action
    MAX_PER_PAGE = 1000

    include API::Actions::MessageJSON
    include API::Actions::ParamsInspection

    # FIXME: 全体で設定しないとapplication/jsonを返さない。
    #       この設定で正しいのかは不明。
    #       https://hanakai.org/learn/hanami/v2.3/upgrade-notes#use-new-formats-config-for-actions
    #       これによると、depractedらしいが、代わりになる設定がわからない。
    #       https://hanakai.org/learn/hanami/v2.3/actions/formats-and-media-types
    #       これによるとresponse.format = :jsonらしいのだが、うまくいかなかった。なんで？
    format :json

    if Hanami.env?(:development)
      config.formats.accept :json, :html
    else
      config.formats.accept :json
    end

    # skip to verify csrf token if Sec-Fetch-Site is same-origin.
    def verify_csrf_token?(req, *)
      super && req.get_header("HTTP_SEC_FETCH_SITE") != "same-origin"
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

    # handle_exception InvalidCSRFTokenError => :handle_invalid_csrf_token_error
    handle_exception StandardError => :handle_standard_error

    private def handle_standard_error(request, response, exception)
      logger.error exception
      halt_json request, response, 500
    end

    private def handle_invalid_csrf_token_error(request, response, _exception)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN], was: request_csrf_token(request)
      response.flash[:error] = t("errors.invalid_csrf_token")
      halt_json request, response, 400
    end

    # override private api
    private def view_options(request, response)
      super.merge({status: response.status, location: request.path})
    end
  end
end
