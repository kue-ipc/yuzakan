# auto_register: false
# frozen_string_literal: true

module API
  class Action < Yuzakan::Action
    include API::Actions::MessageJSON

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

    # override handle
    def handle_invalid_csrf_token(request, response)
      logger.warn "CSRF attack", expected:  request.session[:_csrf_token],
        was: request.params[:_csrf_token]
      halt_json 422, errors: [I18n.t("errors.invalid_csrf_token")]
    end
  end
end
