# frozen_string_literal: true

require_relative "../../web/controllers/connection"

module API
  module Connection
    include Web::Connection

    private def reply_session_timeout
      halt_json 401, errors: ["セッションがタイムアウトしました。"]
    end
  end
end
