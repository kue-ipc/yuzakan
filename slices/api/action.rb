# auto_register: false
# frozen_string_literal: true

module API
  class Action < Yuzakan::Action
    MAX_STRING_SIZE = 255
    MAX_TEXT_SIZE = 65535

    include API::Actions::MessageJSON
    include API::Actions::ParamsInspection

    config.formats.accept :json

    # override reply

    private def reply_session_timeout(request, response)
      halt_json request, response, 401, message: t("errors.session_timeout")
    end

    private def reply_unauthenticated(request, response)
      halt_json request, response, 401, message: t("errors.authenticated?")
    end

    private def reply_untrusted(request, response)
      halt_json request, response, 401, message: t("errors.trusted?")
    end

    private def reply_unauthorized(request, response)
      halt_json request, response, 403, message: t("errors.authorized?")
    end

    # override handle

    handle_exception StandardError => :handle_standard_error

    private def handle_standard_error(request, response, exception)
      logger.error exception
      halt_json request, response, 500, message: t("response_messages.internal_server_error"), exception: exception
    end

    private def handle_invalid_csrf_token_error(request, response, _exception)
      logger.warn "CSRF attack", expected: request.session[CSRF_TOKEN], was: request_csrf_token(request),
        fetch_site: req.get_header("HTTP_SEC_FETCH_SITE")
      halt_json request, response, 400, message: t("errors.invalid_csrf_token")
    end

    private def handle_not_found(request, response, exception)
      if exception.is_a?(ROM::TupleCountMismatchError)
        halt_json request, response, 404, message: t("errors.non_existent")
      else
        halt_json request, response, 404, message: t("response_messages.not_found")
      end
    end

    # override private api
    private def view_options(request, response)
      super.merge({status: response.status, location: request.path})
    end
  end
end
